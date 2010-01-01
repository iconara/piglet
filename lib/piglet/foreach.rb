module Piglet
  class Foreach # :nodoc:
    include Relation
    
    def initialize(relation, field_expressions)
      @sources, @field_expressions = [relation], [field_expressions].flatten
    end
    
    def to_s
      "FOREACH #{@sources.first.alias} GENERATE #{field_expressions_string}"
    end
    
  private
  
    def field_expressions_string
      @field_expressions.map { |fe| fe.to_s }.join(', ')
    end
  end
  
  module Relation
    # FOREACH ... GENERATE
    #
    #   x.foreach { |r| r.a }            # => FOREACH x GENERATE a
    #   x.foreach { |r| [r.a, r.b] }     # => FOREACH x GENERATE a, b
    #   x.foreach { |r| r.a.max }        # => FOREACH x GENERATE MAX(a)
    #   x.foreach { |r| r.a.avg.as(:b) } # => FOREACH x GENERATE AVG(a) AS b
    #
    #--
    #
    # TODO: FOREACH a { b GENERATE c }
    def foreach
      Foreach.new(self, yield(self))
    end
  end
end