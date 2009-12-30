module Piglet
  class Assignment # :nodoc:
    attr_reader :target
    
    def initialize(relation)
      @target = relation
    end
    
    def to_s
      "#{@target.alias} = #{@target.to_s}"
    end
  end
end