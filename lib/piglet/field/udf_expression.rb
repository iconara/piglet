module Piglet
  module Field
    class UdfExpression
      include Field
      
      def initialize(ali4s, *args)
        @alias, @args = ali4s, args
      end
      
      def to_s
        "#{@alias}(#{args_to_s(@args)})"
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
    end
  end
end