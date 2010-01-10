module Piglet
  module Field
    class BinaryConditional
      include Field
      
      def initialize(test, if_true, if_false)
        @test, @if_true, @if_false = test, if_true, if_false
        @type = case @if_true
        when Field
          @if_true.type
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
          
      def to_s
        "(#{@test} ? #{@if_true} : #{@if_false})"
      end
    end
  end
end