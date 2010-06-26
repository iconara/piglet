# encoding: utf-8

module Piglet
  module Field
    class SuffixExpression # :nodoc:
      include Field
    
      def initialize(operator, expression, options=nil)
        options ||= {}
        @operator, @expression = operator, expression
        @type = options[:type] || expression.type
        @predecessors = [expression]
      end
    
      def simple?
        false
      end
    
      def to_s
        "#{parenthesise(@expression)} #{@operator}"
      end
      
      def to_inner_s
        "#{paranthesise(@expression.field_alias)} #{@operator}"
      end
    end
  end
end