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
      end
    
      def simple?
        true
      end
    
      def field(name)
        Reference.new(name, self, :explicit_ancestry => true)
      end
    
      def method_missing(name, *args)
        if name.to_s =~ /^\w+$/ && args.empty?
          field(name)
        else
          super
        end
      end
    
      def [](n)
        field("\$#{n}")
      end
    
      def to_s
        if @explicit_ancestry
          if @parent.respond_to?(:alias)
            "#{@parent.alias}.#{@name.to_s}"
          else
            "#{@parent}.#{@name.to_s}"
          end
        else
          @name.to_s
        end
      end
    end
  end
end