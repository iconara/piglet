module Piglet
  module Field
    class CallExpression # :nodoc:
      include Field
    
      def initialize(function_name, inner_expression, options=nil)
        options ||= {}
        @function_name, @inner_expression = function_name, inner_expression
        @type = options[:type] || inner_expression.type
      end
      
      def simple?
        false
      end
    
      def to_s
        "#{@function_name}(#{@inner_expression})"
      end
    end
  end
end