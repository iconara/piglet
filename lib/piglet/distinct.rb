module Piglet
  class Distinct # :nodoc:
    include Relation
    
    def initialize(relation, options={})
      options ||= {}
      @sources, @parallel = [relation], options[:parallel]
    end
    
    def to_s
      str  = "DISTINCT #{@sources.first.alias}"
      str << " PARALLEL #{@parallel}" if @parallel
      str
    end
  end
  
  module Relation
    # DISTINCT
    #
    #   x.distinct                 # => DISTINCT x
    #   x.distinct(:parallel => 5) # => DISTINCT x PARALLEL 5
    def distinct(options={})
      Distinct.new(self, options)
    end
  end
end