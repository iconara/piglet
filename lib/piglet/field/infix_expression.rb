module Piglet
  module Field
    class InfixExpression # :nodoc:
      include Field
    
      def initialize(operator, left_expression, right_expression, options=nil)
        options ||= {}
        @operator, @left_expression, @right_expression = operator, left_expression, right_expression
        @type = options[:type] || expression_type(left_expression, right_expression)
      end
    
      def simple?
        false
      end
    
      def to_s
        "#{parenthesise(@left_expression)} #{@operator} #{parenthesise(@right_expression)}"
      end
      
    private
    
      def expression_type(left, right)
        left_type = subexpression_type(left)
        right_type = subexpression_type(right)
        
        if left_type == :double || right_type == :double
          :double
        elsif left_type == :float || right_type == :float
          :float
        else
          left_type
        end
      end
      
      def subexpression_type(expr)
        case expr
        when Field
          expr.type
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