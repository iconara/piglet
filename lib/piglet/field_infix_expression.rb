module Piglet
  class FieldInfixExpression # :nodoc:
    include FieldExpressionFunctions
    
    def initialize(operator, left_expression, right_expression)
      @operator, @left_expression, @right_expression = operator, left_expression, right_expression
    end
    
    def to_s
      "#{@left_expression} #{@operator} #{@right_expression}"
    end
  end
end