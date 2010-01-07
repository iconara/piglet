# :main: README.rdoc
module Piglet # :nodoc:
  VERSION = '0.1.1'
  
  autoload :Assignment, 'piglet/assignment'
  autoload :Interpreter, 'piglet/interpreter'
  
  module Inout
    autoload :Describe, 'piglet/inout/describe'
    autoload :Dump, 'piglet/inout/dump'
    autoload :Explain, 'piglet/inout/explain'
    autoload :Illustrate, 'piglet/inout/illustrate'
    autoload :Load, 'piglet/inout/load'
    autoload :Output, 'piglet/inout/output'
    autoload :StorageTypes, 'piglet/inout/storage_types'
    autoload :Store, 'piglet/inout/store'
  end
  
  module Relation
    autoload :Cogroup, 'piglet/relation/cogroup'
    autoload :Cross, 'piglet/relation/cross'
    autoload :Distinct, 'piglet/relation/distinct'
    autoload :Filter, 'piglet/relation/filter'
    autoload :Foreach, 'piglet/relation/foreach'
    autoload :Group, 'piglet/relation/group'
    autoload :Join, 'piglet/relation/join'
    autoload :Limit, 'piglet/relation/limit'
    autoload :Order, 'piglet/relation/order'
    autoload :Relation, 'piglet/relation/relation'
    autoload :Sample, 'piglet/relation/sample'
    autoload :Split, 'piglet/relation/split'
    autoload :Stream, 'piglet/relation/stream'
    autoload :Union, 'piglet/relation/union'
  end
  
  module Field
    autoload :BinaryConditional, 'piglet/field/binary_conditional'
    autoload :CallExpression, 'piglet/field/call_expression'
    autoload :InfixExpression, 'piglet/field/infix_expression'
    autoload :Literal, 'piglet/field/literal'
    autoload :Operators, 'piglet/field/operators'
    autoload :PrefixExpression, 'piglet/field/prefix_expression'
    autoload :Reference, 'piglet/field/reference'
    autoload :Rename, 'piglet/field/rename'
    autoload :SuffixExpression, 'piglet/field/suffix_expression'
  end

  class NotSupportedError < StandardError; end
end