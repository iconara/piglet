module Piglet
  class Distinct
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
end