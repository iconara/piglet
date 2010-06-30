# encoding: utf-8
module Piglet
  module Field
    class MapValue
      include Field
      
      def initialize(key, parent)
        @key, @predecessors = key, [parent]
      end
      
      def to_s
        "#{@predecessors.first}##{@key}"
      end

      def to_inner_s
        "#{@predecessors.first.field_alias}##{@key}"
      end
    end
  end
end