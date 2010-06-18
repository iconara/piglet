# encoding: utf-8

require 'set'


module Piglet
  class Interpreter
    def initialize(&block)
      @top_level_statements = [ ]
      
      interpret(&block) if block_given?
    end
  
    def interpret(&block)
      if block_given?
        instance_eval(&block)
      end
    
      self
    end
    
    def to_pig_latin(&block)
      interpret(&block) if block_given?
      
      return '' if @top_level_statements.empty?
      
      handled_relations = Set.new
      statements = [ ]
      
      @top_level_statements.each do |top_level_statement|
        if top_level_statement.respond_to?(:relation) && ! top_level_statement.relation.nil?
          assignments(top_level_statement.relation, handled_relations).each do |assignment|
            statements << assignment
          end
        end
        statements << top_level_statement
      end
      
      statements.flatten.map { |s| s.to_s }.join(";\n") + ";\n"
    end
    
    def next_relation_alias
      @counter ||= 0
      @counter += 1
      "relation_#{@counter}"
    end

  protected

    # LOAD
    #
    #   load('some/path')                                         # => LOAD 'some/path'
    #   load('some/path', :using => 'Xyz')                        # => LOAD 'some/path' USING Xyz
    #   load('some/path', :using => :pig_storage)                 # => LOAD 'some/path' USING PigStorage
    #   load('some/path', :schema => [:a, :b])                    # => LOAD 'some/path' AS (a, b)
    #   load('some/path', :schema => %w(a b c d))                 # => LOAD 'some/path' AS (a, b, c, d)
    #   load('some/path', :schema => [%w(a chararray), %(b int)]) # => LOAD 'some/path' AS (a:chararray, b:int)
    #
    #--
    #
    # NOTE: the syntax load('path', :schema => {:a => :chararray, :b => :int})
    # would be nice, but the order of the keys can't be guaranteed in Ruby 1.8.
    def load(path, options={})
      Inout::Load.new(path, self, options)
    end
  
    # STORE
    #
    #   store(x, 'some/path') # => STORE x INTO 'some/path'
    #   store(x, 'some/path', :using => 'Xyz') # => STORE x INTO 'some/path' USING Xyz
    #   store(x, 'some/path', :using => :pig_storage) # => STORE x INTO 'some/path' USING PigStorage
    def store(relation, path, options={})
      @top_level_statements << Inout::Store.new(relation, path, options)
    end
  
    # DUMP
    #
    #   dump(x) # => DUMP x
    def dump(relation)
      @top_level_statements << Inout::Dump.new(relation)
    end
  
    # ILLUSTRATE
    #
    #   illustrate(x) # => ILLUSTRATE x
    def illustrate(relation)
      @top_level_statements << Inout::Illustrate.new(relation)
    end
  
    # DESCRIBE
    #
    #   describe(x) # => DESCRIBE x
    def describe(relation)
      @top_level_statements << Inout::Describe.new(relation)
    end
  
    # EXPLAIN
    #
    #   explain    # => EXPLAIN
    #   explain(x) # => EXPLAIN(x)
    def explain(relation=nil)
      @top_level_statements << Inout::Explain.new(relation)
    end
    
    # REGISTER
    #
    #   register 'path/to/lib.jar' # => REGISTER path/to/lib.jar
    def register(path)
      @top_level_statements << Udf::Register.new(path)
    end
    
    # DEFINE
    #
    #   define('test', :function => 'com.example.Test')             # => DEFINE test com.example.Test
    #   define('test', :command => 'test.rb')                       # => DEFINE test `test.rb`
    #   define('test', :command => 'test.rb', :input => :stdin)     # => DEFINE test `test.rb` INPUT(stdin)
    #   define('test', :command => 'test.rb', :input => 'path/x')   # => DEFINE test `test.rb` INPUT('path/x')
    #   define('test', :command => 'test.rb', :output => :stdout)   # => DEFINE test `test.rb` OUTPUT(stdout)
    #   define('test', :command => 'test.rb', :ship => 'a/b/c')     # => DEFINE test `test.rb` SHIP('a/b/c')
    #   define('test', :command => 'test.rb', :cache => ['x', 'y']) # => DEFINE test `test.rb` CACHE('x', 'y')
    #
    # The <code>:input</code> and <code>:output</code> options can take pretty
    # complicated definitions in addition to the examples above:
    #
    #   :input => {:from => :stdin, :using => :pig_storage}                  # => INPUT(stdin USING PigStorage)
    #   :output => {:to => :stdout, :using => 'MySerializer'}                # => OUTPUT(stdout USING MySerializer)
    #   :output => [{:to => :stdout, :using => 'MySerializer'}, 'some/path'] # => OUTPUT(stdout USING MySerializer, 'some/path')
    def define(ali4s, options=nil)
      @top_level_statements << Udf::Define.new(ali4s, options)
      unless respond_to?(ali4s)
        def metaclass
          class << self
            return self
          end
        end
        metaclass.send(:define_method, ali4s) do |*args|
          Field::UdfExpression.new(ali4s, *args)
        end
      end
    end
    
    # %declare
    #
    #   declare(:my_var, 'value')                  # => %declare my_var 'value'
    #   declare('quote', "He said 'hello!'")       # => %declare quote 'He said \'hello!\''
    #   declare('cmd', 'uniq', :backticks => true) # => %declare cmd `uniq`
    def declare(name, value, options=nil)
      @top_level_statements << Param::Declare.new(name, value, options)
    end
    
    # %default
    #
    #   default(:my_var, 'value')                  # => %default my_var 'value'
    #   default('quote', "He said 'hello!'")       # => %default quote 'He said \'hello!\''
    #   default('cmd', 'uniq', :backticks => true) # => %default cmd `uniq`
    def default(name, value, options=nil)
      @top_level_statements << Param::Default.new(name, value, options)
    end
    
  private
  
    def assignments(relation, ignore_set)
      return [] if ignore_set.include?(relation)
      assignment = Assignment.new(relation)
      ignore_set << relation
      if relation.sources
        (relation.sources.map { |source| assignments(source, ignore_set) } + [assignment]).flatten
      else
        [assignment]
      end
    end
  end
  
private

  class Assignment # :nodoc:
    attr_reader :target

    def initialize(relation)
      @target = relation
    end

    def to_s
      "#{@target.alias} = #{@target.to_s}"
    end
  end
end