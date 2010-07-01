# encoding: utf-8

module Piglet
  module Field
    class CallExpression # :nodoc:
      include Field
    
      def initialize(function_name, inner_expression, options=nil)
        options ||= {}
        @function_name, @inner_expression = function_name, inner_expression
        @type = options[:type] || inner_expression.type
        @predecessors = [inner_expression]
      end
      
      def simple?
        false
      end
    
      def to_s(inner=false)
        if inner
          "#{@function_name}(#{@inner_expression.field_alias})"
        else
          "#{@function_name}(#{@inner_expression})"
        end
      end
      
      def to_inner_s
        "#{@function_name}(#{@inner_expression.field_alias})"
      end
    end
  end
end