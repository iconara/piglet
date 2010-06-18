# encoding: utf-8

module Piglet
  module Relation
    class Filter # :nodoc:
      include Relation
    
      def initialize(relation, interpreter, expression)
        @sources, @interpreter, @expression = [relation], interpreter, expression
      end
    
      def to_s
        "FILTER #{@sources.first.alias} BY #{@expression}"
      end
    end
  end
end