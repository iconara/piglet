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
      Inout::Load.new(path, options)
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
    
    # Support for binary conditions, a.k.a. the ternary operator.
    #
    #   x.test(x.a > x.b, x.a, x.b) # => (a > b ? a : b)
    # 
    # Should only be used in the block given to #filter and #foreach
    def test(test, if_true, if_false)
      Field::BinaryConditional.new(test, if_true, if_false)
    end
    
    # Support for literals in FOREACH … GENERATE blocks.
    #
    #   x.foreach { |r| [literal("hello").as(:hello)] } # => FOREACH x GENERATE 'hello' AS hello
    def literal(obj)
      Field::Literal.new(obj)
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