module Piglet
  module Storing # :nodoc:
    attr_reader :relation
    
    def initialize(relation)
      @relation = relation
    end
    
    def to_s
      "#{self.class.name.split(/::/).last.upcase} #{@relation.alias}"
    end
  end
end