module Piglet
  class Cross
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
end