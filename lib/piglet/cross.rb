module Piglet
  class Cross # :nodoc:
    include Relation
    
    def initialize(relations, options={})
      options ||= {}
      @sources, @parallel = relations, options[:parallel]
    end
    
    def to_s
      str  = "CROSS #{source_aliases.join(', ')}"
      str << " PARALLEL #{@parallel}" if @parallel
      str
    end
  
  private
    
    def source_aliases
      @sources.map { |s| s.alias }
    end
  end
  
  module Relation
    # CROSS
    #
    #   x.cross(y)                      # => CROSS x, y
    #   x.cross(y, z, w)                # => CROSS x, y, z, w
    #   x.cross([y, z], :parallel => 5) # => CROSS x, y, z, w PARALLEL 5
    def cross(*args)
      relations, options = split_at_options(args)
      Cross.new(([self] + relations).flatten, options)
    end
  end
end