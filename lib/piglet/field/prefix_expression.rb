module Piglet
  module Field
    class PrefixExpression # :nodoc:
      include Field
    
      def initialize(operator, expression, space_between=true)
        @operator, @expression, @space_between = operator, expression, space_between
      end
    
      def simple?
        true
      end
    
      def to_s
        if @space_between
          "#{@operator} #{parenthesise(@expression)}"
        else
          "#{@operator}#{parenthesise(@expression)}"
        end
      end
    end
  end
end