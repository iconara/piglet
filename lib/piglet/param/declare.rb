module Piglet
  module Param
    class Declare
      include ParameterStatement
      def initialize(name, value, options=nil)
        options ||= {}
        @kind, @name, @value, @backticks = 'declare', name, value, options[:backticks]
      end
    end
  end
end