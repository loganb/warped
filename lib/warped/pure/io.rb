
module Warped::Pure
  class IO
    attr_reader :drive, :io, :type, :reqs

    def initialize(drive, io, type)
      @drive = drive
      @io    = io
      @type  = type
      @reqs  = Hash.new { |h,k| h[k] = [] }
    end
    
    def read(request)
      enqueue(request, :read)
    end

    def write(request)
      enqueue(request, :write)
    end
    
    def close
      io.close
    end
    
    def closed?
      io.closed?
    end
    
    protected

    #
    # The Warped::Drive calls this with completed requests
    # 
    def completed(request, op)
      request.complete!
    end

    def enqueue(request, op)
      request.begin!
      reqs[op] << request
      drive.submit_handle(self)
    end
    
    
    def self.synchronous_read(handle, request)
      raise unless request.offset.nil? #Pipes don't have offsets
      buf = handle.io.read(request.len)
      request.buffer << buf
      request.result = buf.length
    end
    
    def self.synchronous_write(handle, request)
      raise unless request.offset.nil? #pipes don't have offsets
      raise unless request.len.nil? #writes don't require a len, entire buffer is written
      
      handle.io.write(request.buffer)
      request.result = request.buffer.length
    end
  end
end