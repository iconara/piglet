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