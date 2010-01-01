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
  
  module Relation
    # LIMIT
    #
    #   x.limit(10) # => LIMIT x 10
    def limit(n)
      Limit.new(self, n)
    end
  end
end