# encoding: utf-8

module Piglet
  module Relation
    class Union # :nodoc:
      include Relation
    
      def initialize(relations, interpreter)
        @sources, @interpreter = relations, interpreter
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