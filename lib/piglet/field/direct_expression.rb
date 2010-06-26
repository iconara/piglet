# encoding: utf-8

module Piglet
  module Field
    class DirectExpression
      include Field
      
      attr_reader :expression
      
      def initialize(expression, ali4s)
        @expression, @alias = ali4s
        @predecessors = [expression]
      end
      
      def to_s
        @expression
      end
      
      def method_missing(name, *args)
        if name.to_s =~ /^\w+$/ && args.empty?
          field(name)
        else
          super
        end
      end
    end
  end
end