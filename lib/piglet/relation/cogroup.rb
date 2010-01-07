module Piglet
  module Relation
    class Cogroup # :nodoc:
      include Relation
    
      def initialize(relation, description)
        @join_fields = description.reject { |k, v| ! (k.is_a?(Relation)) }
        @sources = @join_fields.keys
        @parallel = description[:parallel]
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