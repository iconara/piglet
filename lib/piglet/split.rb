module Piglet
  class Split # :nodoc:
    include Relation
    
    
    def initialize(relation, expressions)
      @sources, @expressions = [relation], expressions
      @shard_map = create_shards
    end
    
    def shards
      @shard_map.keys
    end
    
    def to_s
      "SPLIT #{@sources.first.alias} INTO #{split_strings}"
    end
    
  private
  
    def create_shards
      Hash[*@expressions.map { |expr| [RelationShard.new(self), expr] }.flatten]
    end
  
    def split_strings
      shards.map { |relation| "#{relation.alias} IF #{@shard_map[relation]}" }.join(', ')
    end
  end
  
  class RelationShard # :nodoc:
    include Relation
    
    def initialize(split)
      @sources = [split]
    end
    
    def to_s
      self.alias
    end
  end
end