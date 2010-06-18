# encoding: utf-8

module Piglet
  module Relation
    class Distinct # :nodoc:
      include Relation
    
      def initialize(relation, interpreter, options={})
        options ||= {}
        @sources, @interpreter, @parallel = [relation], interpreter, options[:parallel]
      end
    
      def to_s
        str  = "DISTINCT #{@sources.first.alias}"
        str << " PARALLEL #{@parallel}" if @parallel
        str
      end
    end
  end
end