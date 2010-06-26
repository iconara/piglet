# encoding: utf-8

module Piglet
  module Relation
    class NestedForeach
      include Relation
      
      TAB = "  "
      
      def initialize(relation, interpreter, expressions)
        @sources, @interpreter, @expressions = [relation], interpreter, expressions
      end
      
      def schema
        description = @field_expressions.map { |expr| [expr.name, expr.type] }
        Piglet::Schema::Tuple.parse(description)
      end
      
      def to_s
        str = "FOREACH #{@sources.first.alias} {\n"
        str << block_expressions.map { |expression| TAB + "#{expression.field_alias} = #{expression.to_inner_s};\n" }.join
        str << TAB + "GENERATE " + (@expressions.map { |expression| expression.field_alias}.join(",")) + ";\n"
        str << "}"
      end
      
    private
    
      def block_expressions
        handled = Set.new
        handled.add @relation
        intermediates = @expressions.map { |expression| intermediates(expression, handled) }.flatten
      end
      
      def intermediates(expression, handled)
        result = []
        unless handled.member? expression
          if expression.is_a? Field::Field
            expression.predecessors.each { |predecessor| result += intermediates(predecessor, handled) }
            result += [expression]
            handled.add(expression)
          end
        end
        result
      end
    end
  end
end