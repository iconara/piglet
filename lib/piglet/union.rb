module Piglet
  class Union # :nodoc:
    include Relation
    
    def initialize(*relations)
      @sources = relations
    end
    
    def to_s
      "UNION #{source_aliases.join(', ')}"
    end
    
  private
  
    def source_aliases
      @sources.map { |s| s.alias }
    end
  end
  
  module Relation
    # UNION
    #
    #   x.union(y)    # => UNION x, y
    #   x.union(y, z) # => UNION x, y, z
    def union(*relations)
      Union.new(*([self] + relations))
    end
  end
end