module Piglet
  class Literal
    include FieldExpressionFunctions
    
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
    
  private
  
    def escape(str)
      str.gsub(/(')/) { |m| "\\#{$1}" }
    end
  end
end