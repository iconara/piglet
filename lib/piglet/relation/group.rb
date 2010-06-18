# encoding: utf-8

module Piglet
  module Relation
    class Group # :nodoc:
      include Relation
    
      def initialize(relation, interpreter, grouping, options={})
        options ||= {}
        @sources, @interpreter, @grouping, @parallel = [relation], interpreter, grouping, options[:parallel]
      end
      
      def schema
        parent = @sources.first
        parent_schema = parent.schema
        if @grouping.size == 1
          group_type = parent.schema.field_type(@grouping.first)
        else
          group_type = Piglet::Schema::Tuple.parse(
            @grouping.map { |field| [field, parent_schema.field_type(field)] }
          )
        end
        Piglet::Schema::Tuple.parse([
          [:group, group_type],
          [parent.alias.to_sym, Piglet::Schema::Bag.new(parent_schema)]
        ])
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