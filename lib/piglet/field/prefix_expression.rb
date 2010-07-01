# encoding: utf-8

module Piglet
  module Field
    class PrefixExpression # :nodoc:
      include Field
      
      attr_reader :operator
    
      def initialize(operator, expression, space_between=true, options=nil)
        options ||= {}
        @operator, @expression, @space_between = operator, expression, space_between
        @type = options[:type] || expression.type
        @predecessors = [expression]
      end
    
      def simple?
        false
      end
    
      def to_s(inner=false)
        expr = if inner then @expression.field_alias else @expression end
        
        if @space_between
          "#{@operator} #{parenthesise(expr)}"
        else
          "#{@operator}#{parenthesise(expr)}"
        end
      end
      
      def to_inner_s
        if @space_between
          "#{@operator} #{parenthesise(@expression.field_alias)}"
        else
          "#{@operator}#{paranthesis(@expression.field_alias)}"
        end
      end
    end
  end
end