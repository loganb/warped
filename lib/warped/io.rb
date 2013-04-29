
module Warped
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
  end
end

require_relative 'io/pipe'