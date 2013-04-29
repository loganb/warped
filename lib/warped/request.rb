module Warped
  class Request
    attr_accessor :result

    def initialize
      @is_complete = @is_working = false
    end
    
    #
    #  Clears the complete flag so that the request can be reused.
    #
    def reset!
      raise if working?
      @is_complete = false
    end
    
    def begin!
      raise if working?
      raise if complete?
      @is_working = true
    end
    
    def complete!
      raise if complete?
      raise unless working?
      @is_complete = true
      @is_working  = false
    end
    
    def complete?
      @is_complete
    end
    
    def working?
      @is_working
    end
  end
  
  class IORequest < Request
    attr_reader :buffer, :len, :offset

    def initialize(buffer = nil, len = nil, offset = nil)
      super()
      @buffer = buffer
      @len = len
      @offset = offset
    end
  end
  
end