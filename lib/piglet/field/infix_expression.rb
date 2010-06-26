# encoding: utf-8

module Piglet
  module Field
    class InfixExpression # :nodoc:
      include Field
      
      attr_reader :operator
    
      def initialize(operator, left_expression, right_expression, options=nil)
        options ||= {}
        @operator, @left_expression, @right_expression = operator, left_expression, right_expression
        if options[:type]
          @type = options[:type]
        else
          @type = determine_type(@left_expression, @right_expression)
        end
        @predecessors = [left_expression, right_expression]
      end
    
      def simple?
        false
      end
    
      def to_s
        left  = @left_expression
        right = @right_expression

        if left.respond_to?(:operator) && left.operator != @operator
          left = parenthesise(left)
        end
        
        if right.respond_to?(:operator) && right.operator != @operator
          right = parenthesise(right)
        end
        
        "#{left} #{@operator} #{right}"
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