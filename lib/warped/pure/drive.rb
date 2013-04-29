require 'set'

require_relative 'io'

module Warped
  module Pure
    class Drive
      attr_reader :work_items
      attr_reader :handles
      
      def initialize
        @handles    = Set.new
        @work_items = Set.new
        @reqs       = Hash.new { |h,k| h[k] = Set.new }

        #This block runs in another thread
        @pool       = Warped::Pool.new do |*args|
          (handle, op, request) = args
          handle.class.send(:"synchronous_#{op}", handle, request)
          args # For the completion logic
        end
      end
      
      #
      # opens a pipe, return [read_end, write_end]
      #
      def pipe
        ::IO.pipe.collect { |p| from_io(p, :pipe) }
      end
      
      #
      # Creates an async IO handle out of a Ruby ::IO
      #
      def from_io(io, type)
        raise unless type == :pipe
        raise unless io.is_a?(::IO)
        
        IO.new(self, io, type).tap { |io| handles.add(io) }
      end
      
      def complete(timeout = nil)
        work_items.each do |h|
          h.reqs.each_pair do |op, reqs|
            next if reqs.empty?
            req = reqs.shift

            @pool.submit(h, op, req)
          end
        end
        work_items.clear
        results = @pool.result(timeout)
        
        if(results) #A request object finished
          (h, op, request) = results
          h.send(:completed, request, op)
          request
        end
      end
      
      def close
        handles.each do |h|
          h.close
        end
      end
      
      #
      # Used internally to submit requests
      #
      def submit_handle(handle)
        work_items << handle
      end
    end
  end
end