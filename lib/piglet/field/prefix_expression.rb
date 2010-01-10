module Piglet
  module Field
    class PrefixExpression # :nodoc:
      include Field
    
      def initialize(operator, expression, space_between=true, options=nil)
        options ||= {}
        @operator, @expression, @space_between = operator, expression, space_between
        @type = options[:type] || expression.type
      end
    
      def simple?
        true
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