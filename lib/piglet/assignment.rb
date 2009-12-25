module Piglet
  class Assignment
    def initialize(name)
      @name = name
    end
    
    def <<(relation)
      @relation = relation
    end
    
    def to_pig_latin
      "#{@name} = #{@relation.to_pig_latin}"
    end
  end
end