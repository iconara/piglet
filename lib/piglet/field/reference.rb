# encoding: utf-8

module Piglet
  module Field
    class Reference # :nodoc:
      include Field
    
      def initialize(name, relation=nil, options=nil)
        options ||= {}
        @name, @parent = name, relation
        @explicit_ancestry = options[:explicit_ancestry] || false
        @type = options[:type]
        @predecessors = [relation] unless relation.nil?
      end
    
      def simple?
        true
      end

      def method_missing(name, *args)
        if name.to_s =~ /^\w+$/ && args.empty?
          field(name)
        else
          super
        end
      end
    
      def to_s(inner=false)
        if @explicit_ancestry
          if @parent.respond_to?(:alias)
            "#{@parent.alias}.#{@name.to_s}"
          else
            expr = if inner then @parent.field_alias else @parent end
            "#{expr}.#{@name.to_s}"
          end
        else
          @name.to_s
        end
      end
    end
  end
end