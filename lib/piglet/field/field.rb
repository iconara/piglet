module Piglet
  module Field
    module Field # :nodoc:
      SYMBOLIC_OPERATORS = [:==, :>, :<, :>=, :<=, :%, :+, :-, :*, :/]
      FUNCTIONS = [:avg, :count, :max, :min, :size, :sum, :tokenize]

      attr_reader :name, :type
    
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
        PrefixExpression.new('NOT', self, :type => :boolean)
      end
    
      def null?
        SuffixExpression.new('is null', self, :type => :boolean)
      end
    
      def not_null?
        SuffixExpression.new('is not null', self, :type => :boolean)
      end
    
      def cast(type)
        PrefixExpression.new("(#{type.to_s})", self, :type => type.to_sym)
      end
    
      def matches(pattern)
        regex_options_pattern = /^\(\?.+?:(.*)\)$/
        pattern = pattern.to_s.sub(regex_options_pattern, '\1') if pattern.is_a?(Regexp) && pattern.to_s =~ regex_options_pattern
        InfixExpression.new('matches', self, "'#{pattern.to_s}'", :type => :boolean)
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
    end
  end
end