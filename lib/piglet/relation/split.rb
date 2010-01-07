module Piglet
  module Relation
    class Split # :nodoc:
      include Relation
    
      def initialize(relation, expressions)
        @sources, @expressions = [relation], expressions
        @shard_map = create_shards
      end
    
      def shards
        @shard_map.values_at(*@expressions)
      end
    
      def to_s
        split_strings = @expressions.map do |expression|
          "#{@shard_map[expression].alias} IF #{expression}"
        end
        
        "SPLIT #{@sources.first.alias} INTO #{split_strings.join(', ')}"
      end
    
    private
  
      def create_shards
        @expressions.inject({}) do |map, expr|
          map[expr] = RelationShard.new(self)
          map
        end
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
end