# encoding: utf-8

# :main: README.rdoc
module Piglet # :nodoc:
  VERSION = '0.2.5'
  
  class PigletError < StandardError; end
  class NotSupportedError < PigletError; end
  
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
    autoload :BlockContext, 'piglet/relation/block_context'
    autoload :Cogroup, 'piglet/relation/cogroup'
    autoload :Cross, 'piglet/relation/cross'
    autoload :Distinct, 'piglet/relation/distinct'
    autoload :Filter, 'piglet/relation/filter'
    autoload :Foreach, 'piglet/relation/foreach'
    autoload :NestedForeach, 'piglet/relation/nested_foreach'
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
    autoload :DirectExpression, 'piglet/field/direct_expression'
    autoload :Literal, 'piglet/field/literal'
    autoload :Field, 'piglet/field/field'
    autoload :MapValue, 'piglet/field/map_value'
    autoload :PrefixExpression, 'piglet/field/prefix_expression'
    autoload :Reference, 'piglet/field/reference'
    autoload :Rename, 'piglet/field/rename'
    autoload :SuffixExpression, 'piglet/field/suffix_expression'
    autoload :UdfExpression, 'piglet/field/udf_expression'
  end
  
  module Schema
    autoload :Bag, 'piglet/schema/bag'
    autoload :Tuple, 'piglet/schema/tuple'
    
    class SchemaError < PigletError; end
  end
  
  module Udf
    autoload :Define, 'piglet/udf/define'
    autoload :Register, 'piglet/udf/register'
  end
  
  module Param
    autoload :Declare, 'piglet/param/declare'
    autoload :Default, 'piglet/param/default'
    autoload :ParameterStatement, 'piglet/param/parameter_statement'
  end
end