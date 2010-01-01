module Piglet
  class Group # :nodoc:
    include Relation
    
    def initialize(relation, grouping, options={})
      options ||= {}
      @sources, @grouping, @parallel = [relation], grouping, options[:parallel]
    end
    
    def to_s
      str = "GROUP #{@sources.first.alias} BY "
      if @grouping.size > 1
        str << "(#{@grouping.join(', ')})"
      else
        str << @grouping.first.to_s
      end
      str << " PARALLEL #{@parallel}" if @parallel
      str
    end
  end
  
  module Relation
    # GROUP
    #
    #   x.group(:a)                           # => GROUP x By a
    #   x.group(:a, :b, :c)                   # => GROUP x BY (a, b, c)
    #   x.group([:a, :b, :c], :parallel => 3) # => GROUP x BY (a, b, c) PARALLEL 3
    def group(*args)
      grouping, options = split_at_options(args)
      Group.new(self, [grouping].flatten, options)
    end
  end
end