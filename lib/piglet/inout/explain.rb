module Piglet
  module Inout
    class Explain # :nodoc:
      include Output
    
      def to_s
        if relation.nil?
          "EXPLAIN"
        else
          super
        end
      end
    end
  end
end