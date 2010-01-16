module Piglet
  module Param
    module ParameterStatement
      def to_s
        if @backticks
          v = "`#{@value}`"
        else
          case @value
          when String, Symbol
            v = "'#{escape(@value)}'"
          else
            v = @value
          end
        end
        "%#{@kind} #{@name} #{v}"
      end
      
    private
    
      def escape(str)
        str.to_s.gsub(/('|\\)/) { |m| "\\#{$1}" }
      end
    end
  end
end