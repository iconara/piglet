# encoding: utf-8

module Piglet
  module Relation
    class BlockContext
      def initialize(relation, interpreter)
        @relation, @interpreter = relation, interpreter
      end
      
      # Support for literals in FOREACH … GENERATE blocks.
      #
      #   x.foreach { |r| [literal("hello").as(:hello)] } # => FOREACH x GENERATE 'hello' AS hello
      def literal(obj)
        Field::Literal.new(obj)
      end
      
      # Support for binary conditions, a.k.a. the ternary operator.
      #
      #   x.test(x.a > x.b, x.a, x.b) # => (a > b ? a : b)
      # 
      # Should only be used in the block given to #filter and #foreach
      def test(test, if_true, if_false)
        Field::BinaryConditional.new(test, if_true, if_false)
      end
      
      def [](n)
        @relation.field("\$#{n}")
      end
      
      def method_missing(name, *args)
        if args.size == 0
          @relation.method_missing(name, *args)
        elsif @interpreter.respond_to?(name)
          @interpreter.send(name, *args)
        else
          super
        end
      end
    end
  end
end