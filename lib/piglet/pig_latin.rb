module Piglet
  module PigLatin
  
    def load(path)
      push_statement Load.new(path)
    end

  end
end