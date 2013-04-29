module Warped
  class IO::Pipe < IO
    
    protected

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