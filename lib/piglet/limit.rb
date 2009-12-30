module Piglet
  class Limit # :nodoc:
    include Relation
    
    def initialize(relation, n)
      @sources, @n = [relation], n
    end
    
    def to_s
      "LIMIT #{@sources.first.alias} #{@n}"
    end
  end
end