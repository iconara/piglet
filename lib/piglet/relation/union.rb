module Piglet
  module Relation
    class Union # :nodoc:
      include Relation
    
      def initialize(*relations)
        @sources = [relations].flatten
      end
    
      def to_s
        "UNION #{source_aliases.join(', ')}"
      end
    
    private
  
      def source_aliases
        @sources.map { |s| s.alias }
      end
    end
  end
end