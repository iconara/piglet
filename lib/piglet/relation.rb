module Piglet
  module Relation
    attr_reader :sources

    # The name this relation will get in Pig Latin. Then name is generated when
    # the relation is outputed by the interpreter, and will be unique.
    def alias
      @alias ||= Relation.next_alias
    end
    
    # COGROUP
    #
    #   x.cogroup(y, x => :a, y => :b)                 # => COGROUP x BY a, y BY b
    #   x.cogroup([y, z], x => :a, y => :b, z => :c)   # => COGROUP x BY a, y BY b, z BY c
    #   x.cogroup(y, x => [:a, :b], y => [:c, :d])     # => COGROUP x BY (a, b), y BY (c, d)
    #   x.cogroup(y, x => :a, y => [:b, :inner])       # => COGROUP x BY a, y BY b INNER
    #   x.cogroup(y, x => :a, y => :b, :parallel => 5) # => COGROUP x BY a, y BY b PARALLEL 5
    def cogroup(*args); raise NotSupportedError; end
  
    # JOIN
    #
    #   x.join(y, x => :a, y => :b)                        # => JOIN x BY a, y BY b
    #   x.join([y, z], x => :a, y => :b, z => :c)          # => JOIN x BY a, y BY b, z BY c
    #   x.join(y, x => :a, y => :b, :using => :replicated) # => JOIN x BY a, y BY b USING "replicated"
    #   x.join(y, x => :a, y => :b, :parallel => 5)        # => JOIN x BY a, y BY b PARALLEL 5
    def join(*args); raise NotSupportedError; end
  
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
    def order(*args); raise NotSupportedError; end
  
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