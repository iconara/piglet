module Piglet
  class FieldInfixExpression # :nodoc:
    include FieldExpressionFunctions
    
    def initialize(operator, left_expression, right_expression)
      @operator, @left_expression, @right_expression = operator, left_expression, right_expression
    end
    
    def simple?
      false
    end
    
    def to_s
      "#{parenthesise(@left_expression)} #{@operator} #{parenthesise(@right_expression)}"
    end
  end
end