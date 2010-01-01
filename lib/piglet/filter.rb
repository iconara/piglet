module Piglet
  class Filter
    include Relation
    
    def initialize(relation, expression)
      @sources, @expression = [relation], expression
    end
    
    def to_s
      "FILTER #{@sources.first.alias} BY #{@expression}"
    end
  end
end