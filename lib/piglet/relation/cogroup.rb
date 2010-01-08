module Piglet
  module Relation
    class Cogroup # :nodoc:
      include Relation
    
      def initialize(relation, description)
        @join_fields = description.reject { |k, v| ! (k.is_a?(Relation)) }
        @sources = @join_fields.keys
        @parallel = description[:parallel]
      end
      
      def schema
        first_schema = @sources.first.schema
        join_fields = @join_fields[@sources.first]
        if join_fields.is_a?(Enumerable) && join_fields.size > 1
          group_type = join_fields.map { |f| [f, first_schema.field_type[f]] }
          description = [[:group, :tuple, group_type]]
        else
          description = [[:group, *join_fields]]
        end
        @sources.each do |source|
          description << [source.alias.to_sym, Piglet::Schema::Bag.new(source.schema)]
        end
        Piglet::Schema::Tuple.parse(description)
      end
    
      def to_s
        joins = @sources.map do |s|
          fields = @join_fields[s]
          if fields.is_a?(Enumerable) && fields.size > 1 && (fields.last == :inner || fields.last == :outer)
            inout = fields.last.to_s.upcase
            fields = fields[0..-2]
          end
          if fields.is_a?(Enumerable) && fields.size > 1
            str = "#{s.alias} BY (#{fields.join(', ')})"
          else
            str = "#{s.alias} BY #{fields}"
          end
          str << " #{inout}" if inout
          str
        end
        str  = "COGROUP #{joins.join(', ')}"
        str << " PARALLEL #{@parallel}" if @parallel
        str
      end
    end
  end
end