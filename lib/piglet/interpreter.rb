module Piglet
  
  class Interpreter

    include PigLatin
  
  
    def initialize
      @statements = [ ]
      @last_relation = nil
    end
  
    def interpret(&block)
      if block_given?
        instance_eval(&block)
      else
        push_statement no_op
      end
    
      self
    end
    
    def push_statement(stmt)
      unless @statements.last.is_a?(Assignment)
        @statements << stmt
      end
      stmt
    end
    
    def method_missing(symbol, *args)
      push_statement Assignment.new(symbol)
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