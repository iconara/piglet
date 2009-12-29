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
    
  private
  
    def assignments(relation, ignore_set)
      return [] if ignore_set.include?(relation)
      assignment = Assignment.new(relation)
      if relation.source
        assignments(relation.source, ignore_set) + [assignment]
      else
        [assignment]
      end
    end
    
    def load(path, options={})
      Load.new(path, options)
    end
    
    def store(relation, path, options={})
      @stores << Store.new(relation, path, options)
    end
    
    def dump(relation)
      @stores << Dump.new(relation)
    end
    
    def illustrate(relation)
      @stores << Illustrate.new(relation)
    end
    
    def describe(relation)
      @stores << Describe.new(relation)
    end
    
    def explain(relation=nil)
      @stores << Explain.new(relation)
    end
  end
  
  module Relation
    attr_reader :source
        
    def alias
      @alias ||= Relation.next_alias
    end
    
    # group(:a)                           # => GROUP x By a
    # group(:a, :b, :c)                   # => GROUP x BY (a, b, c)
    # group([:a, :b, :c], :parallel => 3) # => GROUP x BY (a, b, c) PARALLEL 3
    def group(*args)
      grouping = [ ]
      options = nil
      args.each do |a|
        case a
        when Hash
          options = a
          break
        when Array
          grouping += a
        else
          grouping << a
        end
      end
      
      Group.new(self, grouping, options)
    end
    
    def distinct(options={})
      Distinct.new(self, options)
    end

    def hash
      self.alias.hash
    end
    
    def eql?(other)
      other.is_a(Relation) && other.alias == self.alias
    end
    
  private
  
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
      @source, @grouping, @parallel = relation, grouping, options[:parallel]
    end
    
    def to_s
      str = "GROUP #{@source.alias} BY "
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
      @source, @parallel = relation, options[:parallel]
    end
    
    def to_s
      str  = "DISTINCT #{@source.alias}"
      str << " PARALLEL #{@parallel}" if @parallel
      str
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