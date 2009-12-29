require 'set'


module Piglet
  class Interpreter
    def initialize(&block)
      @stores = [ ]
      
      interpret(&block) if block_given?
    end
  
    def interpret(&block)
      if block_given?
        instance_eval(&block)
      end
    
      self
    end
    
    def to_pig_latin
      return '' if @stores.empty?
      
      handled_relations = Set.new
      statements = [ ]
      
      @stores.each do |store|
        unless store.relation.nil?
          assignments(store.relation, handled_relations).each do |assignment|
            statements << assignment
            handled_relations << assignment.target
          end
        end
        statements << store
      end
      
      statements.flatten.map { |s| s.to_s }.join(";\n") + ";\n"
    end
  
  protected
  
    # load('some/path')                                         # => LOAD 'some/path'
    # load('some/path', :using => 'Xyz')                        # => LOAD 'some/path' USING Xyz
    # load('some/path', :using => :pig_storage)                 # => LOAD 'some/path' USING PigStorage
    # load('some/path', :schema => [:a, :b])                    # => LOAD 'some/path' AS (a, b)
    # load('some/path', :schema => %w(a b c d))                 # => LOAD 'some/path' AS (a, b, c, d)
    # load('some/path', :schema => [%w(a chararray), %(b int)]) # => LOAD 'some/path' AS (a:chararray, b:int)
    #
    # NOTE: the syntax load('path', :schema => {:a => :chararray, :b => :int})
    # would be nice, but the order of the keys can't be guaranteed in Ruby 1.8.
    def load(path, options={})
      Load.new(path, options)
    end
  
    # store(x, 'some/path') # => STORE x INTO 'some/path'
    # store(x, 'some/path', :using => 'Xyz') # => STORE x INTO 'some/path' USING Xyz
    # store(x, 'some/path', :using => :pig_storage) # => STORE x INTO 'some/path' USING PigStorage
    def store(relation, path, options={})
      @stores << Store.new(relation, path, options)
    end
  
    # dump(x) # => DUMP x
    def dump(relation)
      @stores << Dump.new(relation)
    end
  
    # illustrate(x) # => ILLUSTRATE x
    def illustrate(relation)
      @stores << Illustrate.new(relation)
    end
  
    # describe(x) # => DESCRIBE x
    def describe(relation)
      @stores << Describe.new(relation)
    end
  
    # explain    # => EXPLAIN
    # explain(x) # => EXPLAIN(x)
    def explain(relation=nil)
      @stores << Explain.new(relation)
    end
  
  private
  
    def assignments(relation, ignore_set)
      return [] if ignore_set.include?(relation)
      assignment = Assignment.new(relation)
      if relation.sources
        (relation.sources.map { |source| assignments(source, ignore_set) } + [assignment]).flatten
      else
        [assignment]
      end
    end
    
  end
  
  module Relation
    attr_reader :sources

    def alias
      @alias ||= Relation.next_alias
    end
    
    # x.group(:a)                           # => GROUP x By a
    # x.group(:a, :b, :c)                   # => GROUP x BY (a, b, c)
    # x.group([:a, :b, :c], :parallel => 3) # => GROUP x BY (a, b, c) PARALLEL 3
    def group(*args)
      grouping, options = split_at_options(args)
      Group.new(self, [grouping].flatten, options)
    end
    
    # x.distinct                 # => DISTINCT x
    # x.distinct(:parallel => 5) # => DISTINCT x PARALLEL 5
    def distinct(options={})
      Distinct.new(self, options)
    end

    # x.cogroup(y, x => :a, y => :b)                 # => COGROUP x BY a, y BY b
    # x.cogroup([y, z], x => :a, y => :b, z => :c)   # => COGROUP x BY a, y BY b, z BY c
    # x.cogroup(y, x => [:a, :b], y => [:c, :d])     # => COGROUP x BY (a, b), y BY (c, d)
    # x.cogroup(y, x => :a, y => [:b, :inner])       # => COGROUP x BY a, y BY b INNER
    # x.cogroup(y, x => :a, y => :b, :parallel => 5) # => COGROUP x BY a, y BY b PARALLEL 5
    def cogroup; raise NotSupportedError; end
    
    # x.cross(y)                      # => CROSS x, y
    # x.cross(y, z, w)                # => CROSS x, y, z, w
    # x.cross([y, z], :parallel => 5) # => CROSS x, y, z, w PARALLEL 5
    def cross(*args)
      relations, options = split_at_options(args)
      Cross.new(([self] + relations).flatten, options)
    end
    
    # x.filter(:a.eql(:b))                   # => FILTER x BY a == b
    # x.filter(:a.gt(:b).and(:c.not_eql(3))) # => FILTER x BY a > b AND c != 3
    def filter; raise NotSupportedError; end
    
    # x.foreach { |r| r.a }            # => FOREACH x GENERATE a
    # x.foreach { |r| [r.a, r.b] }     # => FOREACH x GENERATE a, b
    # x.foreach { |r| r.a.max }        # => FOREACH x GENERATE MAX(a)
    # x.foreach { |r| r.a.avg.as(:b) } # => FOREACH x GENERATE AVG(a) AS b
    #
    # TODO: FOREACH a { b GENERATE c }
    def foreach; raise NotSupportedError; end
    
    # x.join(y, x => :a, y => :b)                        # => JOIN x BY a, y BY b
    # x.join([y, z], x => :a, y => :b, z => :c)          # => JOIN x BY a, y BY b, z BY c
    # x.join(y, x => :a, y => :b, :using => :replicated) # => JOIN x BY a, y BY b USING "replicated"
    # x.join(y, x => :a, y => :b, :parallel => 5)        # => JOIN x BY a, y BY b PARALLEL 5
    def join; raise NotSupportedError; end
    
    # x.limit(10) # => LIMIT x 10
    def limit; raise NotSupportedError; end
    
    # x.order(:a)                      # => ORDER x BY a
    # x.order(:a, :b)                  # => ORDER x BY a, b
    # x.order([:a, :asc], [:b, :desc]) # => ORDER x BY a ASC, b DESC
    # x.order(:a, :parallel => 5)      # => ORDER x BY a PARALLEL 5
    #
    # NOTE: the syntax x.order(:a => :asc, :b => :desc) would be nice, but in
    # Ruby 1.8 the order of the keys cannot be guaranteed.
    def order; raise NotSupportedError; end
    
    # x.sample(5) # => SAMPLE x 5;
    def sample; raise NotSupportedError; end
    
    # TODO: this one is tricky since it's assignment, but also a relation operation
    def split; raise NotSupportedError; end
    
    # x.stream(x, 'cut -f 3')                         # => STREAM x THROUGH `cut -f 3`
    # x.stream([x, y], 'cut -f 3')                    # => STREAM x, y THROUGH `cut -f 3`
    # x.stream(x, 'cut -f 3', :schema => [%w(a int)]) # => STREAM x THROUGH `cut -f 3` AS (a:int)
    #
    # TODO: how to handle DEFINE'd commands?
    def stream(relations, command, options={})
      raise NotSupportedError
    end
    
    # x.union(y)    # => UNION x, y
    # x.union(y, z) # => UNION x, y, z
    def union; raise NotSupportedError; end

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
  
  module LoadAndStore
    def resolve_load_store_function(name)
      case name
      when :pig_storage
        'PigStorage'
      else
        name
      end
    end
  end
  
  module Storing
    attr_reader :relation
    
    def initialize(relation)
      @relation = relation
    end
    
    def to_s
      "#{self.class.name.split(/::/).last.upcase} #{@relation.alias}"
    end
  end
  
  class Assignment
    attr_reader :target
    
    def initialize(relation)
      @target = relation
    end
    
    def to_s
      "#{@target.alias} = #{@target.to_s}"
    end
  end
  
  class Group
    include Relation
    
    def initialize(relation, grouping, options={})
      options ||= {}
      @sources, @grouping, @parallel = [relation], grouping, options[:parallel]
    end
    
    def to_s
      str = "GROUP #{@sources.first.alias} BY "
      if @grouping.size > 1
        str << "(#{@grouping.join(', ')})"
      else
        str << @grouping.first.to_s
      end
      str << " PARALLEL #{@parallel}" if @parallel
      str
    end
  end
  
  class Distinct
    include Relation
    
    def initialize(relation, options={})
      options ||= {}
      @sources, @parallel = [relation], options[:parallel]
    end
    
    def to_s
      str  = "DISTINCT #{@sources.first.alias}"
      str << " PARALLEL #{@parallel}" if @parallel
      str
    end
  end
  
  class Cross
    include Relation
    
    def initialize(relations, options={})
      options ||= {}
      @sources, @parallel = relations, options[:parallel]
    end
    
    def to_s
      str  = "CROSS #{source_aliases.join(', ')}"
      str << " PARALLEL #{@parallel}" if @parallel
      str
    end
  
  private
    
    def source_aliases
      @sources.map { |s| s.alias }
    end
  end
  
  class Load
    include Relation
    include LoadAndStore
    
    def initialize(path, options={})
      options ||= {}
      @path, @using, @schema = path, options[:using], options[:schema]
    end
    
    def to_s
      str  = "LOAD '#{@path}'"
      str << " USING #{resolve_load_store_function(@using)}" if @using
      str << " AS (#{schema_string})" if @schema
      str
    end
    
  private
        
    def schema_string
      @schema.map do |field|
        if field.is_a?(Enumerable)
          field.map { |f| f.to_s }.join(':')
        else
          field.to_s
        end
      end.join(', ')
    end
    
  end
  
  class Store
    include LoadAndStore
    include Storing
    
    def initialize(relation, path, options={})
      @relation, @path, @using = relation, path, options[:using]
    end
    
    def to_s
      str  = super
      str << " INTO '#{@path}'"
      str << " USING #{resolve_load_store_function(@using)}" if @using
      str
    end
  end
  
  class Dump
    include Storing
  end
  
  class Illustrate
    include Storing
  end
  
  class Describe
    include Storing
  end
  
  class Explain
    include Storing
    
    def to_s
      if relation.nil?
        "EXPLAIN"
      else
        super
      end
    end
  end

end