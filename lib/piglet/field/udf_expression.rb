module Piglet
  module Field
    class UdfExpression
      include Field
      
      def initialize(ali4s, *args)
        @alias, @args = ali4s, args
        @predecessors = args.select { |arg| arg.respond_to? :field_alias }
      end
      
      def to_s(inner=false)
        if inner
          "#{@alias}(#{args_to_inner_s(@args)})"
        else
          "#{@alias}(#{args_to_s(@args)})"
        end
      end
      
    private
      
      def args_to_s(arg)
        case arg
        when String
          "'#{escape(arg)}'"
        when Enumerable
          arg.map { |a| args_to_s(a) }.join(', ')
        else
          arg
        end
      end
      
      def args_to_inner_s(arg)
        if arg.is_a? String
          "'#{escape(arg)}'"
        elsif arg.is_a? Enumerable
          arg.map { |a| args_to_inner_s(a) }.join(", ")
        elsif arg.respond_to? :field_alias
          arg.field_alias
        else
          arg.to_s
        end
      end
    end
  end
end