module Piglet
  module Field
    class Literal
      include Operators
    
      def initialize(obj)
        @obj = obj
      end
    
      def to_s
        case @obj
        when Numeric
          @obj.to_s
        else
          "'#{escape(@obj.to_s)}'"
        end
      end
    end
  end
end