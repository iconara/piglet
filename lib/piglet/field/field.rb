# encoding: utf-8

module Piglet
  module Field
    module Field # :nodoc:
      SYMBOLIC_OPERATORS = [:==, :>, :<, :>=, :<=, :%, :+, :-, :*, :/]
      FUNCTIONS = [:avg, :count, :max, :min, :size, :sum, :tokenize]

      attr_reader :name, :type, :predecessors
    
      FUNCTIONS.each do |fun|
        define_method(fun) do
          CallExpression.new(fun.to_s.upcase, self, :type => function_return_type(fun, self.type))
        end
      end

      def empty?
        CallExpression.new('IsEmpty', self, :type => :boolean)
      end
      
      def diff(other)
        raise NotSupportedError
      end
    
      def as(new_name)
        Rename.new(new_name, self)
      end
    
      def not
        PrefixExpression.new('NOT', self, true, :type => :boolean)
      end
    
      def null?
        SuffixExpression.new('is null', self, :type => :boolean)
      end
    
      def not_null?
        SuffixExpression.new('is not null', self, :type => :boolean)
      end
    
      def cast(type)
        PrefixExpression.new("(#{type.to_s})", self, true, :type => type.to_sym)
      end
    
      def matches(pattern)
        regex_options_pattern = /^\(\?.+?:(.*)\)$/
        pattern = pattern.to_s.sub(regex_options_pattern, '\1') if pattern.is_a?(Regexp) && pattern.to_s =~ regex_options_pattern
        InfixExpression.new('matches', self, "'#{pattern.to_s}'", :type => :boolean)
      end
    
      def neg
        PrefixExpression.new('-', self, false, :type => self.type)
      end
    
      def ne(other)
        InfixExpression.new('!=', self, other, :type => :boolean)
      end
    
      def and(other)
        InfixExpression.new('AND', self, other, :type => :boolean)
      end
    
      def or(other)
        InfixExpression.new('OR', self, other, :type => :boolean)
      end
    
      SYMBOLIC_OPERATORS.each do |op|
        define_method(op) do |other|
          InfixExpression.new(op.to_s, self, other, :type => symbolic_operator_return_type(op, self, other))
        end
      end
      
      def field_alias
        @field_alias ||= Field.next_alias
      end
      
      def predecessors
        @predecessors ||= []
      end
      
      def distinct
        DirectExpression.new("DISTINCT #{field_alias}", self)
      end
      
      def limit(size)
        DirectExpression.new("LIMIT #{field_alias} #{size}", self)
      end
      
      def sample(rate)
        DirectExpression.new("SAMPLE #{field_alias} #{rate}", self)
      end
      
      def order(*args)
        fields, options = split_at_options(args)
        fields = *fields
        expression = Relation::Order.new(self, @interpreter, fields, options).to_s
        DirectExpression.new(expression, self)
      end
      
      def filter(&block)
        dummy_relation = DummyRelation.new(self.send(:alias))
        context = Relation::BlockContext.new(dummy_relation, @interpreter)
        expression = context.instance_eval(&block)
        DirectExpression.new("FILTER #{field_alias} BY #{expression}", self)
      end
    
    protected
    
      def field(name)
        Reference.new(name, self, :explicit_ancestry => true)
      end
      
      def self.next_alias
        @@counter ||= 0
        ali4s = "field_#{@@counter}"
        @@counter += 1
        ali4s
      end
  
      def parenthesise(expr)
        if expr.respond_to?(:simple?) && ! expr.simple?
          "(#{expr})"
        else
          expr.to_s
        end
      end
      
      def escape(str)
        str.gsub(/("|'|\\)/) { |m| "\\#{$1}" }
      end
      
      def function_return_type(function_name, expression_type)
        case function_name
        when :avg, :sum
          case expression_type
          when :int, :long
            :long
          when :float, :double, :bytearray
            :double
          else
            nil
          end
        when :count, :size
          :long
        when :max, :min
          expression_type
        when :tokenize
          :bag
        else
          nil
        end
      end
      
      def symbolic_operator_return_type(operator, left_expression, right_expression)
        case operator
        when :==, :>, :<, :>=, :<=
          :boolean
        when :%
          :int
        else # :+, :-, :*, :/
          nil
        end
      end
      
      def expression_type(expression)
        case expression
        when Field
          expression.type
        when Integer
          :int
        when Numeric
          :float
        when true, false
          :boolean
        else
          nil
        end
      end
      
      def split_at_options(parameters)
        if parameters.last.is_a? Hash
          [parameters[0..-2], parameters.last]
        else
          [parameters, nil]
        end
      end
      
      class DummyRelation
        include Relation::Relation
        attr_reader :alias        
        def initialize(ali4s)
          @alias = ali4s
        end
      end
    end  
  end
end