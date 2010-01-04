module Piglet
  module FieldExpressionFunctions # :nodoc:
    SYMBOLIC_OPERATORS = [:==, :>, :<, :>=, :<=, :%, :+, :-, :*, :/]
    FUNCTIONS = [:avg, :count, :diff, :max, :min, :size, :sum, :tokenize]
    
    FUNCTIONS.each do |fun|
      define_method(fun) { FieldFunctionExpression.new(fun.to_s.upcase, self) }
    end

    def empty?
      FieldFunctionExpression.new('IsEmpty', self)
    end
    
    def as(new_name)
      FieldRename.new(new_name, self)
    end
    
    def not
      FieldPrefixExpression.new('NOT', self)
    end
    
    def null?
      FieldSuffixExpression.new('is null', self)
    end
    
    def not_null?
      FieldSuffixExpression.new('is not null', self)
    end
    
    def cast(type)
      FieldPrefixExpression.new("(#{type.to_s})", self)
    end
    
    def matches(pattern)
      regex_options_pattern = /^\(\?.+?:(.*)\)$/
      pattern = pattern.to_s.sub(regex_options_pattern, '\1') if pattern.is_a?(Regexp) && pattern.to_s =~ regex_options_pattern
      FieldInfixExpression.new('matches', self, "'#{pattern.to_s}'")
    end
    
    def neg
      FieldPrefixExpression.new('-', self, false)
    end
    
    def ne(other)
      FieldInfixExpression.new('!=', self, other)
    end
    
    def and(other)
      FieldInfixExpression.new('AND', self, other)
    end
    
    def or(other)
      FieldInfixExpression.new('OR', self, other)
    end
    
    SYMBOLIC_OPERATORS.each do |op|
      define_method(op) { |other| FieldInfixExpression.new(op.to_s, self, other) }
    end
    
  protected
  
    def parenthesise(expr)
      if expr.respond_to?(:simple?) && ! expr.simple?
        "(#{expr})"
      else
        expr.to_s
      end
    end
  end
end