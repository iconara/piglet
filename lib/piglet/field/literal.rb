module Piglet
  module Field
    class Literal
      include Field
    
      def initialize(obj)
        @obj = obj
        @type = literal_type(obj)
      end
    
      def to_s
        case @obj
        when Numeric
          @obj.to_s
        else
          "'#{escape(@obj.to_s)}'"
        end
      end
      
    private
    
      def literal_type(obj)
        case obj
        when String
          :chararray
        when Integer
          :int
        when Numeric
          :float
        else
          :bytearray
        end
      end
    end
  end
end