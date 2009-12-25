module Piglet
  module PigLatin
  
    def load(path)
      load = Load.new(path)
      @statements << load
      load
    end

  end
end