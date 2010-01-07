module Piglet
  module Relation
    class Foreach # :nodoc:
      include Relation
    
      def initialize(relation, field_expressions)
        @sources, @field_expressions = [relation], [field_expressions].flatten
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