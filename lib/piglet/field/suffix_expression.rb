module Piglet
  module Field
    class SuffixExpression # :nodoc:
      include Field
    
      def initialize(operator, expression)
        @operator, @expression = operator, expression
      end
    
      def simple?
        false
      end
    
      def to_s
        "#{parenthesise(@expression)} #{@operator}"
      end
    end
  end
end