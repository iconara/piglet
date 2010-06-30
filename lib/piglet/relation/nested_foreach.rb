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
        str << TAB + "GENERATE " + @expressions.map { |expression| (expression.respond_to? :field_alias) ? expression.field_alias : expression.to_inner_s }.join(",") + ";\n"
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
          if expression.is_a? Field::Field or expression.is_a? Field::Rename
            expression.predecessors.each { |predecessor| result += intermediates(predecessor, handled) }
            handled.add(expression)
          end
          
          # We don't assign intermediate vars for renames
          if expression.is_a? Field::Field
            result += [expression] unless expression.is_a? Field::Rename
          end
        end
        result
      end
    end
  end
end