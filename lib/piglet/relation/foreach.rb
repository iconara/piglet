# encoding: utf-8

module Piglet
  module Relation
    class Foreach # :nodoc:
      include Relation
    
      def initialize(relation, interpreter, field_expressions)
        @sources, @interpreter, @field_expressions = [relation], interpreter, [field_expressions].flatten
      end
      
      def schema
        description = @field_expressions.map { |expr| [expr.name, expr.type] }
        Piglet::Schema::Tuple.parse(description)
      end
    
      def to_s
        "FOREACH #{@sources.first.alias} GENERATE #{field_expressions_string}"
      end
    
    private
  
      def field_expressions_string
        @field_expressions.map { |fe| fe.to_s }.join(', ')
      end
    end
  end
end