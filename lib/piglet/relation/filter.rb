# encoding: utf-8

module Piglet
  module Relation
    class Filter # :nodoc:
      include Relation
    
      def initialize(relation, expression)
        @sources, @expression = [relation], expression
      end
    
      def to_s
        "FILTER #{@sources.first.alias} BY #{@expression}"
      end
    end
  end
end