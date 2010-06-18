# encoding: utf-8

module Piglet
  module Relation
    class Sample # :nodoc:
      include Relation
    
      def initialize(relation, interpreter, n)
        @sources, @interpreter, @n = [relation], interpreter, n
      end
    
      def to_s
        "SAMPLE #{@sources.first.alias} #{@n}"
      end
    end
  end
end