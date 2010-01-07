# :main: README.rdoc
module Piglet # :nodoc:
  VERSION = '0.1.1'
  
  autoload_files = %w(
    assignment
    cogroup
    cross
    describe
    distinct
    dump
    explain
    filter
    foreach
    group
    illustrate
    interpreter
    join
    limit
    load
    load_and_store
    order
    relation
    sample
    split
    store
    storing
    stream
    union
  )
  
  autoload_files.each do |f|
    c = f.split('_').map { |s| s.capitalize }.join.to_sym
    p = "piglet/#{f}"
    autoload c, p
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