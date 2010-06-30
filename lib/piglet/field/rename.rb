# encoding: utf-8

module Piglet
  module Field
    class Rename # :nodoc:
      attr_reader :name, :type, :predecessors
      
      def initialize(name, field_expression)
        @name, @field_expression, @type = name, field_expression, field_expression.type
        @predecessors = [field_expression]
      end
      
      def to_s
        "#{@field_expression} AS #{@name}"
      end
      
      def to_inner_s
        "#{@field_expression.field_alias} AS #{@name}"
      end
    end
  end
end