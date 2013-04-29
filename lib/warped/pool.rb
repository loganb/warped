require 'thread'

module Warped
  class Pool
    #A sentinel value for when a worker has no result
    EMPTY = Object.new
    
    #
    # Takes a block that the workers execute
    #
    def initialize(&block)
      @threads = [] #Protected by @lock, list of available threads
      @results = [] #List of available results
      @block   = block #Block to execute work
      
      @lock = Mutex.new
      @cv   = ConditionVariable.new #Signalled when a thread is returned
    end
    
    #
    # Execute the block in the thread pool
    #
    def submit(*args)
      t = nil
      
      #Search existing threads for a completed one
      @lock.synchronize do
        while(t = @threads.pop)
          r = t.result
          @results.push(r) if r && r != EMPTY

          if(t.process(args))
            return #block has been submitted to this worker
          else 
            #thread is dead, drop it from the list
          end
        end
      end

      #No workers were available, spawn one
      Worker.new(self, args, @block)
    end
    
    def result(timeout = nil)
      # Try to fill @results if there's nothing
      if(@results.empty?)
        #If there's nothing left on the results stack, try to get stuff from the @thread pool
        @lock.synchronize do
          begin #Retry point
            @threads.reverse_each do |t|
              tmp = t.result!
              #If a thread result has already been emptied, all ones before it on the stack must have been as well
              break if tmp == EMPTY
              @results.push(tmp) if tmp
            end
        
            #If we still haven't found results, try waiting for them
            if(@results.size == 0 && (!timeout || timeout > 0))
              @cv.wait(@lock, timeout)
              timeout = 0 #Makes un not wait upon retrying
              redo
            end
          end
        end
      end
      
      ret = @results.pop #There may be nothing, this will be then be nil
      raise ret if ret.is_a? StandardError
      ret
    end
    
    def return_worker(worker)
      @lock.synchronize do
        @threads.push(worker)
        @cv.signal if worker.result
      end
    end
  end
  
  class Worker < Thread
    attr_reader :pool, :result
    
    # @working and @args is protected by @lock
    def initialize(pool, args, block)
      @pool    = pool
      @block   = block

      @lock    = Mutex.new
      @cv      = ConditionVariable.new
      @working = true
      @result  = Pool::EMPTY

      #Args of the first job to perform
      @args    = args

      super do
        do_work
      end
    end
    
    def do_work
      @lock.synchronize do
        unless(@args)
          @cv.wait(@lock, 10)

          #We timed out if there's still no args
          unless(@args)
            working = false
            return
          end
        end
      end

      begin
        @result = @block.call(*@args)
      rescue StandardError => e
        @result = e
      ensure
        pool.return_worker(self)
      end
      @result
    end
    
    #
    # Returns true if queued, false if the thread is dying/dead
    #
    def process(args)
      @lock.synchronize do
        return false unless @working
        raise "Invalid!" if(@block)
        @args = args
        @cv.signal
      end
      true
    end
    
    #
    # Returns the current result and resets it to nil
    #
    def result!
      ret = @result
      @result = Pool::EMPTY
      ret
    end
  end
end