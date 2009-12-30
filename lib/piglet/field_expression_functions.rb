module Piglet
  module FieldExpressionFunctions
    def avg
      FieldExpression.new('AVG', self)
    end
  
    def count
      FieldExpression.new('COUNT', self)
    end

    def diff
      FieldExpression.new('DIFF', self)
    end

    def is_empty?
      FieldExpression.new('IsEmpty', self)
    end

    def max
      FieldExpression.new('MAX', self)
    end

    def min
      FieldExpression.new('MIN', self)
    end

    def size
      FieldExpression.new('SIZE', self)
    end

    def sum
      FieldExpression.new('SUM', self)
    end

    def tokenize
      FieldExpression.new('TOKENIZE', self)
    end
    
    def as(new_name)
      FieldRename.new(new_name, self)
    end
  end
end