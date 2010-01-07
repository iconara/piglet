module Piglet
  module Field
    module Operators # :nodoc:
      SYMBOLIC_OPERATORS = [:==, :>, :<, :>=, :<=, :%, :+, :-, :*, :/]
      FUNCTIONS = [:avg, :count, :diff, :max, :min, :size, :sum, :tokenize]
    
      FUNCTIONS.each do |fun|
        define_method(fun) do
          CallExpression.new(fun.to_s.upcase, self)
        end
      end

      def empty?
        CallExpression.new('IsEmpty', self)
      end
    
      def as(new_name)
        Rename.new(new_name, self)
      end
    
      def not
        PrefixExpression.new('NOT', self)
      end
    
      def null?
        SuffixExpression.new('is null', self)
      end
    
      def not_null?
        SuffixExpression.new('is not null', self)
      end
    
      def cast(type)
        PrefixExpression.new("(#{type.to_s})", self)
      end
    
      def matches(pattern)
        regex_options_pattern = /^\(\?.+?:(.*)\)$/
        pattern = pattern.to_s.sub(regex_options_pattern, '\1') if pattern.is_a?(Regexp) && pattern.to_s =~ regex_options_pattern
        InfixExpression.new('matches', self, "'#{pattern.to_s}'")
      end
    
      def neg
        PrefixExpression.new('-', self, false)
      end
    
      def ne(other)
        InfixExpression.new('!=', self, other)
      end
    
      def and(other)
        InfixExpression.new('AND', self, other)
      end
    
      def or(other)
        InfixExpression.new('OR', self, other)
      end
    
      SYMBOLIC_OPERATORS.each do |op|
        define_method(op) do |other|
          InfixExpression.new(op.to_s, self, other)
        end
      end
    
    protected
  
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
    end
  end
end