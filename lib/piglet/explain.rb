module Piglet
  class Explain # :nodoc:
    include Storing
    
    def to_s
      if relation.nil?
        "EXPLAIN"
      else
        super
      end
    end
  end
end