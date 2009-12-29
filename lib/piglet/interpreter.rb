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
      statements = [ ]
      
      @stores.each do |store|
        statements << Assignment.new(store.relation)
        statements << store
      end
      
      #puts statements
      
      if statements.empty?
        ''
      else
        statements.flatten.map { |s| s.to_s }.join(";\n") + ";\n"
      end
    end
    
  private
    
    def load(path, options={})
      Load.new(path, options)
    end
    
    def store(relation, path, options={})
      @stores << Store.new(relation, path, options)
    end
  end
  
  module Relation
    def self.next_name
      @counter ||= 0
      @counter += 1
      "relation_#{@counter}"
    end
    
    def name
      @name ||= Relation.next_name
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
  
  class Assignment
    def initialize(relation)
      @relation = relation
    end
    
    def to_s
      "#{@relation.name} = #{@relation.to_s}"
    end
  end
  
  class Load
    include Relation
    include LoadAndStore
    
    def initialize(path, options={})
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
    
    attr_reader :relation
    
    def initialize(relation, path, options={})
      @relation, @path, @using = relation, path, options[:using]
    end
    
    def to_s
      str  = "STORE #{relation.name} INTO '#{@path}'"
      str << " USING #{resolve_load_store_function(@using)}" if @using
      str
    end
  end
end