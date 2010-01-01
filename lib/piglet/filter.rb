module Piglet
  class Filter # :nodoc:
    include Relation
    
    def initialize(relation, expression)
      @sources, @expression = [relation], expression
    end
    
    def to_s
      "FILTER #{@sources.first.alias} BY #{@expression}"
    end
  end
  
  module Relation
    # FILTER
    #
    #   x.filter { |r| r.a == r.b }            # => FILTER x BY a == b
    #   x.filter { |r| r.a > r.b && r.c != 3 } # => FILTER x BY a > b AND c != 3
    def filter
      Filter.new(self, yield(self))
    end
  end
end