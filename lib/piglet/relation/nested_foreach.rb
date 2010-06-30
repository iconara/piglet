# encoding: utf-8

module Piglet
  module Relation
    class NestedForeach
      include Relation
      
      def initialize(relation, interpreter, expressions)
        @sources, @interpreter, @expressions = [relation], interpreter, expressions
      end
      
      def schema
        description = @field_expressions.map { |expr| [expr.name, expr.type] }
        Piglet::Schema::Tuple.parse(description)
      end
      
      def to_s
        block_assignments = block_expressions.map do |expression|
          "\t#{expression.field_alias} = #{expression.to_s(true)};\n"
        end
        
        generate_fields = @expressions.map do |expression| 
          if expression.respond_to?(:field_alias)
            expression.field_alias
          else
            expression.to_s(true)
          end
        end
        
        str = "FOREACH #{@sources.first.alias} {\n"
        str << block_assignments.join
        str << "\tGENERATE " + generate_fields.join(', ') + ";\n"
        str << "}"
      end
      
    private
    
      def block_expressions
        handled = Set.new
        handled.add(@relation)
        intermediates = @expressions.map { |expression| intermediates(expression, handled) }.flatten
      end
      
      def intermediates(expression, handled)
        result = []
        unless handled.member?(expression)
          if expression.is_a? Field::Field or expression.is_a? Field::Rename
            expression.predecessors.each { |predecessor| result += intermediates(predecessor, handled) }
            handled.add(expression)
          end

          if expression.is_a?(Field::Field) && ! expression.is_a?(Field::Rename)
            result << expression
          end
        end
        result
      end
    end
  end
end