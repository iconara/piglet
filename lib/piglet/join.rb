module Piglet
  class Join # :nodoc:
    include Relation
    
    def initialize(relation, description)
      @join_fields = Hash[*description.select { |k, v| k.is_a?(Relation) }.flatten]
      @sources = @join_fields.keys
      @using = description[:using]
      @parallel = description[:parallel]
    end
    
    def to_s
      joins = @sources.map { |s| "#{s.alias} BY #{@join_fields[s]}" }.join(', ')
      str  = "JOIN #{joins}"
      str << " USING \"#{@using.to_s}\"" if @using
      str << " PARALLEL #{@parallel}" if @parallel
      str
    end
  end
end