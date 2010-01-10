module Piglet
  module Field
    class InfixExpression # :nodoc:
      include Field
    
      def initialize(operator, left_expression, right_expression, options=nil)
        options ||= {}
        @operator, @left_expression, @right_expression = operator, left_expression, right_expression
        if options[:type]
          @type = options[:type]
        else
          @type = determine_type(@left_expression, @right_expression)
        end
      end
    
      def simple?
        false
      end
    
      def to_s
        "#{parenthesise(@left_expression)} #{@operator} #{parenthesise(@right_expression)}"
      end
      
    private
    
      def determine_type(left, right)
        left_type = expression_type(left)
        right_type = expression_type(right)

        if left_type == :double || right_type == :double
          :double
        elsif left_type == :float || right_type == :float
          :float
        elsif left_type == :long || right_type == :long
          :long
        else
          left_type
        end
      end
    end
  end
end