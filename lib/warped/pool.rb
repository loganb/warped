require 'thread'

module Warped
  class Pool
    #A sentinel value for when a worker has no result
    EMPTY = Object.new
    
    def initialize
      @threads = [] #Protected by @lock
      @results = []
      
      @lock = Mutex.new
      @cv   = ConditionVariable.new #Signalled when a thread is returned
    end
    
    #
    # Execute the block in the thread pool
    #
    def submit(&block)
      t = nil
      while(t = @lock.synchronize { @threads.pop })
        #Handle results
        r = t.result
        @results.push(r) if r && r != EMPTY

        if(t.process(&block))
          return #block has been submitted to this worker
        else 
          #thread is dead, drop it from the list
        end
      end
      #No workers were available, spawn one
      unless(t) 
        Worker.new(self, &block)
      end
    end
    
    def result(timeout = nil)
      ret = @results.pop
      return ret if ret
      
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
        
      @results.pop #Maybe there's something there
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
    
    # @working and @block are protected by @lock
    def initialize(pool, &block)
      @pool    = pool
      @block   = block if(block_given?)

      @lock    = Mutex.new
      @cv      = ConditionVariable.new
      @working = true
      @result  = Pool::EMPTY
      super do
        do_work
      end
    end
    
    def do_work
      b = nil
      @lock.synchronize do
        b = @block
        unless(b)
          @cv.wait(@lock, 10)
          #We timed out
          unless(b)
            working = false
            return
          end
        end
      end

      @result = b.call
      pool.return_worker(self)
    end
    
    #
    # Returns true if queued, false if the thread is dying/dead
    #
    def process(&b)
      @lock.synchronize do
        return false unless @working
        raise "Invalid!" if(@block)
        @block = b
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