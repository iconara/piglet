module Piglet
  module Relation
    class Group # :nodoc:
      include Relation
    
      def initialize(relation, grouping, options={})
        options ||= {}
        @sources, @grouping, @parallel = [relation], grouping, options[:parallel]
      end
      
      def schema
        parent = @sources.first
        if @grouping.size == 1
          group_type = parent.schema.field_type(@grouping.first)
        else
          group_type = :tuple
        end
        Piglet::Schema::Tuple.new([[:group, group_type], [parent.alias.to_sym, :bag]])
      end
    
      def to_s
        str = "GROUP #{@sources.first.alias} BY "
        if @grouping.size > 1
          str << "(#{@grouping.join(', ')})"
        else
          str << @grouping.first.to_s
        end
        str << " PARALLEL #{@parallel}" if @parallel
        str
      end
    end
  end
end