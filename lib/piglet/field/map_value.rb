# encoding: utf-8
module Piglet
  module Field
    class MapValue
      include Field
      
      def initialize(key, parent)
        @key, @predecessors = key, [parent]
      end
      
      def to_s(inner=false)
        expr = if inner then @predecessors.first.field_alias else @predecessors.first end
        "#{expr}##{@key}"
      end
    end
  end
end