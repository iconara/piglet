module Piglet
  class FieldExpression
    include FieldExpressionFunctions
    
    def initialize(name, inner_expression, options=nil)
      options ||= {}
      @name, @inner_expression = name, inner_expression
      @new_name = options[:as]
    end
    
    def to_s
      "#{@name}(#{@inner_expression})"
    end
  end
end