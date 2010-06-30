# encoding: utf-8

module Piglet
  module Field
    class DirectExpression
      include Field
      
      attr_reader :string
      
      def initialize(string, predecessor)
        @string = string
        @predecessors = [predecessor]
      end
      
      def to_s
        @string
      end
      
      def to_inner_s
        to_s
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