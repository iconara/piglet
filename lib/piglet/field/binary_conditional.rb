module Piglet
  module Field
    class BinaryConditional
      include Operators
      
      def initialize(test, if_true, if_false)
        @test, @if_true, @if_false = test, if_true, if_false
      end
    
      def to_s
        "(#{@test} ? #{@if_true} : #{@if_false})"
      end
    end
  end
end