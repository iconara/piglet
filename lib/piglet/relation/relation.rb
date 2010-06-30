# encoding: utf-8

module Piglet
  module Relation
    module Relation
      attr_reader :sources

      # The name this relation will get in Pig Latin. Then name is generated when
      # the relation is outputed by the interpreter, and will be unique.
      def alias
        @alias ||= @interpreter.next_relation_alias
      end
  
      # GROUP
      #
      #   x.group(:a)                           # => GROUP x By a
      #   x.group(:a, :b, :c)                   # => GROUP x BY (a, b, c)
      #   x.group([:a, :b, :c], :parallel => 3) # => GROUP x BY (a, b, c) PARALLEL 3
      def group(*args)
        grouping, options = split_at_options(args)
        Group.new(self, @interpreter, [grouping].flatten, options)
      end
  
      # DISTINCT
      #
      #   x.distinct                 # => DISTINCT x
      #   x.distinct(:parallel => 5) # => DISTINCT x PARALLEL 5
      def distinct(options={})
        Distinct.new(self, @interpreter, options)
      end

      # COGROUP
      #
      #   x.cogroup(x => :a, y => :b)                 # => COGROUP x BY a, y BY b
      #   x.cogroup(x => :a, y => :b, z => :c)        # => COGROUP x BY a, y BY b, z BY c
      #   x.cogroup(x => [:a, :b], y => [:c, :d])     # => COGROUP x BY (a, b), y BY (c, d)
      #   x.cogroup(x => :a, y => [:b, :inner])       # => COGROUP x BY a, y BY b INNER
      #   x.cogroup(x => :a, y => :b, :parallel => 5) # => COGROUP x BY a, y BY b PARALLEL 5
      def cogroup(description)
        Cogroup.new(self, @interpreter, description)
      end
  
      # CROSS
      #
      #   x.cross(y)                      # => CROSS x, y
      #   x.cross(y, z, w)                # => CROSS x, y, z, w
      #   x.cross([y, z], :parallel => 5) # => CROSS x, y, z, w PARALLEL 5
      def cross(*args)
        relations, options = split_at_options(args)
        Cross.new(([self] + relations).flatten, @interpreter, options)
      end
  
      # FILTER
      #
      #   x.filter { a == b }          # => FILTER x BY a == b
      #   x.filter { a > b && c == 3 } # => FILTER x BY a > b AND c == 3
      def filter(&block)
        context = BlockContext.new(self, @interpreter)
        Filter.new(self, @interpreter, context.instance_eval(&block))
      end
  
      # FOREACH ... GENERATE
      #
      #   x.foreach { a }            # => FOREACH x GENERATE a
      #   x.foreach { [a, b] }       # => FOREACH x GENERATE a, b
      #   x.foreach { a.max }        # => FOREACH x GENERATE MAX(a)
      #   x.foreach { a.avg.as(:b) } # => FOREACH x GENERATE AVG(a) AS b
      #
      # See #nested_foreach for FOREACH ... { ... GENERATE }
      def foreach(&block)
        context = BlockContext.new(self, @interpreter)
        Foreach.new(self, @interpreter, context.instance_eval(&block))
      end
      
      # FOREACH ... { ... GENERATE }
      #
      #   x.nested_foreach { [a.distinct] } # => FOREACH x { a1 = DISTINCT a; GENERATE a1 }
      #
      # See #foreach for FOREACH ... GENERATE
      def nested_foreach(&block)
        context = BlockContext.new(self, @interpreter)
        NestedForeach.new(self, @interpreter, context.instance_eval(&block))
      end
  
      # JOIN
      #
      #   x.join(x => :a, y => :b)                        # => JOIN x BY a, y BY b
      #   x.join(x => :a, y => :b, z => :c)               # => JOIN x BY a, y BY b, z BY c
      #   x.join(x => :a, y => :b, :using => :replicated) # => JOIN x BY a, y BY b USING "replicated"
      #   x.join(x => :a, y => :b, :parallel => 5)        # => JOIN x BY a, y BY b PARALLEL 5
      def join(description)
        Join.new(self, @interpreter, description)
      end
  
      # LIMIT
      #
      #   x.limit(10) # => LIMIT x 10
      def limit(n)
        Limit.new(self, @interpreter, n)
      end
  
      # ORDER
      #
      #   x.order(:a)                      # => ORDER x BY a
      #   x.order(:a, :b)                  # => ORDER x BY a, b
      #   x.order([:a, :asc], [:b, :desc]) # => ORDER x BY a ASC, b DESC
      #   x.order(:a, :parallel => 5)      # => ORDER x BY a PARALLEL 5
      #
      #--
      #
      # NOTE: the syntax x.order(:a => :asc, :b => :desc) would be nice, but in
      # Ruby 1.8 the order of the keys cannot be guaranteed.
      def order(*args)
        fields, options = split_at_options(args)
        fields = *fields
        Order.new(self, @interpreter, fields, options)
      end
  
      # SAMPLE
      #
      #   x.sample(5) # => SAMPLE x 5;
      def sample(n)
        Sample.new(self, @interpreter, n)
      end
    
      # SPLIT
      #
      #   y, z = x.split { [a <= 3, b > 4] } # => SPLIT x INTO y IF a <= 3, z IF a > 4
      def split(&block)
        context = BlockContext.new(self, @interpreter)
        Split.new(self, @interpreter, context.instance_eval(&block)).shards
      end
  
      # STREAM
      #
      #   x.stream(:command => 'cut -f 3')       # => STREAM x THROUGH `cut -f 3`
      #   x.stream(:cmd)                         # => STREAM x THROUGH cmd
      #   x.stream(y, :command => 'cut -f 3')    # => STREAM x, y THROUGH `cut -f 3`
      #   x.stream(:cmd, :schema => [%w(a int)]) # => STREAM x THROUGH cmd AS (a:int)
      def stream(*args)
        fields, options = split_at_options(args)
        Stream.new(self, @interpreter, fields, options)
      end
  
      # UNION
      #
      #   x.union(y)    # => UNION x, y
      #   x.union(y, z) # => UNION x, y, z
      def union(*relations)
        Union.new(([self] + relations).flatten, @interpreter)
      end

      def field(name)
        type = schema.field_type(name) rescue nil
        Field::Reference.new(name, self, :type => type)
      end
      
      def schema
        if @sources.nil?
          raise Piglet::Schema::SchemaError, 'Could not determine the schema since there was no source relation and this relation does not define its own schema'
        elsif @sources.size > 1
          raise Piglet::Schema::SchemaError, 'Could not determine the schema since there were more than one source relation'
        else
          @sources.first.schema
        end
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

      def hash
        self.alias.hash
      end
  
      def eql?(other)
        other.is_a?(Relation) && other.alias == self.alias
      end
  
    private

      def split_at_options(parameters)
        if parameters.last.is_a? Hash
          [parameters[0..-2], parameters.last]
        else
          [parameters, nil]
        end
      end
    end
  end
end