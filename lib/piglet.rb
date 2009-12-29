module Piglet
  autoload :Assignment,   'piglet/assignment'
  autoload :Cross,        'piglet/cross'
  autoload :Describe,     'piglet/describe'
  autoload :Distinct,     'piglet/distinct'
  autoload :Dump,         'piglet/dump'
  autoload :Explain,      'piglet/explain'
  autoload :Group,        'piglet/group'
  autoload :Illustrate,   'piglet/illustrate'
  autoload :Interpreter,  'piglet/interpreter'
  autoload :Limit,        'piglet/limit'
  autoload :LoadAndStore, 'piglet/load_and_store'
  autoload :Load,         'piglet/load'
  autoload :Relation,     'piglet/relation'
  autoload :Sample,       'piglet/sample'
  autoload :Store,        'piglet/store'
  autoload :Storing,      'piglet/storing'
  autoload :Union,        'piglet/union'

  class NotSupportedError < StandardError; end
end