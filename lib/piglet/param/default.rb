module Piglet
  module Param
    class Default
      include ParameterStatement
      def initialize(name, value, options=nil)
        options ||= {}
        @kind, @name, @value, @backticks = 'default', name, value, options[:backticks]
      end
    end
  end
end