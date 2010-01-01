module Piglet
  class Field # :nodoc:
    include FieldExpressionFunctions
    
    def initialize(name, relation=nil, options=nil)
      options ||= {}
      @name, @parent = name, relation
      @explicit_ancestry = options[:explicit_ancestry] || false
    end
    
    def method_missing(name, *args)
      if name.to_s =~ /^\w+$/ && args.empty?
        Field.new(name, self, :explicit_ancestry => true)
      else
        super
      end
    end
    
    def [](n)
      Field.new("\$#{n}", self, :explicit_ancestry => true)
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