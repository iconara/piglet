module Piglet
  class Sample # :nodoc:
    include Relation
    
    def initialize(relation, n)
      @sources, @n = [relation], n
    end
    
    def to_s
      "SAMPLE #{@sources.first.alias} #{@n}"
    end
  end
  
  module Relation
    # SAMPLE
    #
    #   x.sample(5) # => SAMPLE x 5;
    def sample(n)
      Sample.new(self, n)
    end
  end
end