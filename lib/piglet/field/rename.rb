module Piglet
  module Field
    class Rename # :nodoc:
      def initialize(new_name, field_expression)
        @new_name, @field_expression = new_name, field_expression
      end
    
      def to_s
        "#{@field_expression} AS #{@new_name}"
      end
    end
  end
end