module Piglet
  
  class Interpreter

    include PigLatin
  
  
    def initialize
      @statements = [ ]
    end
  
    def interpret(&block)
      if block_given?
        instance_eval(&block)
      else
        no_op
      end
    
      self
    end
  
    def to_pig_latin
      @str = @statements.map { |stmt| stmt.to_pig_latin }.join(";\n")
      @str << ';' unless @str.empty?
      @str
    end
  
  private

    def no_op
      NoOp.new
    end
  
  end

end