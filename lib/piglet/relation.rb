module Piglet
  module Relation
    attr_reader :sources

    # The name this relation will get in Pig Latin. Then name is generated when
    # the relation is outputed by the interpreter, and will be unique.
    def alias
      @alias ||= Relation.next_alias
    end
  
    # GROUP
    #
    #   x.group(:a)                           # => GROUP x By a
    #   x.group(:a, :b, :c)                   # => GROUP x BY (a, b, c)
    #   x.group([:a, :b, :c], :parallel => 3) # => GROUP x BY (a, b, c) PARALLEL 3
    def group(*args)
      grouping, options = split_at_options(args)
      Group.new(self, [grouping].flatten, options)
    end
  
    # DISTINCT
    #
    #   x.distinct                 # => DISTINCT x
    #   x.distinct(:parallel => 5) # => DISTINCT x PARALLEL 5
    def distinct(options={})
      Distinct.new(self, options)
    end

    # COGROUP
    #
    #   x.cogroup(y, x => :a, y => :b)                 # => COGROUP x BY a, y BY b
    #   x.cogroup([y, z], x => :a, y => :b, z => :c)   # => COGROUP x BY a, y BY b, z BY c
    #   x.cogroup(y, x => [:a, :b], y => [:c, :d])     # => COGROUP x BY (a, b), y BY (c, d)
    #   x.cogroup(y, x => :a, y => [:b, :inner])       # => COGROUP x BY a, y BY b INNER
    #   x.cogroup(y, x => :a, y => :b, :parallel => 5) # => COGROUP x BY a, y BY b PARALLEL 5
    def cogroup(*args); raise NotSupportedError; end
  
    # CROSS
    #
    #   x.cross(y)                      # => CROSS x, y
    #   x.cross(y, z, w)                # => CROSS x, y, z, w
    #   x.cross([y, z], :parallel => 5) # => CROSS x, y, z, w PARALLEL 5
    def cross(*args)
      relations, options = split_at_options(args)
      Cross.new(([self] + relations).flatten, options)
    end
  
    # FILTER
    #
    #   x.filter { |r| r.a == r.b }            # => FILTER x BY a == b
    #   x.filter { |r| r.a > r.b && r.c != 3 } # => FILTER x BY a > b AND c != 3
    def filter
      Filter.new(self, yield(self))
    end
  
    # FOREACH ... GENERATE
    #
    #   x.foreach { |r| r.a }            # => FOREACH x GENERATE a
    #   x.foreach { |r| [r.a, r.b] }     # => FOREACH x GENERATE a, b
    #   x.foreach { |r| r.a.max }        # => FOREACH x GENERATE MAX(a)
    #   x.foreach { |r| r.a.avg.as(:b) } # => FOREACH x GENERATE AVG(a) AS b
    #
    #--
    #
    # TODO: FOREACH a { b GENERATE c }
    def foreach
      Foreach.new(self, yield(self))
    end
  
    # JOIN
    #
    #   x.join(x => :a, y => :b)                        # => JOIN x BY a, y BY b
    #   x.join(x => :a, y => :b, z => :c)               # => JOIN x BY a, y BY b, z BY c
    #   x.join(x => :a, y => :b, :using => :replicated) # => JOIN x BY a, y BY b USING "replicated"
    #   x.join(x => :a, y => :b, :parallel => 5)        # => JOIN x BY a, y BY b PARALLEL 5
    def join(description)
      Join.new(self, description)
    end
  
    # LIMIT
    #
    #   x.limit(10) # => LIMIT x 10
    def limit(n)
      Limit.new(self, n)
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
      Order.new(self, fields, options)
    end
  
    # SAMPLE
    #
    #   x.sample(5) # => SAMPLE x 5;
    def sample(n)
      Sample.new(self, n)
    end
    
    # SPLIT
    #
    #   y, z = x.split { |r| [r.a <= 3, r.b > 4]} # => SPLIT x INTO y IF a <= 3, z IF a > 4
    def split
      Split.new(self, yield(self)).shards
    end
  
    # STREAM
    #
    #   x.stream(x, 'cut -f 3')                         # => STREAM x THROUGH `cut -f 3`
    #   x.stream([x, y], 'cut -f 3')                    # => STREAM x, y THROUGH `cut -f 3`
    #   x.stream(x, 'cut -f 3', :schema => [%w(a int)]) # => STREAM x THROUGH `cut -f 3` AS (a:int)
    #
    #--
    #
    # TODO: how to handle DEFINE'd commands?
    def stream(relations, command, options={})
      raise NotSupportedError
    end
  
    # UNION
    #
    #   x.union(y)    # => UNION x, y
    #   x.union(y, z) # => UNION x, y, z
    def union(*relations)
      Union.new(*([self] + relations))
    end

    def method_missing(name, *args)
      if name.to_s =~ /^\w+$/ && args.empty?
        Field.new(name, self)
      else
        super
      end
    end
    
    def [](n)
      Field.new("\$#{n}", self)
    end

    def hash
      self.alias.hash
    end
  
    def eql?(other)
      other.is_a(Relation) && other.alias == self.alias
    end
  
  private

    def split_at_options(parameters)
      if parameters.last.is_a? Hash
        [parameters[0..-2], parameters.last]
      else
        [parameters, nil]
      end
    end

    def self.next_alias
      @counter ||= 0
      @counter += 1
      "relation_#{@counter}"
    end
  end
end