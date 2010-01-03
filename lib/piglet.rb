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
    field
    field_expression_functions
    field_function_expression
    field_infix_expression
    field_prefix_expression
    field_rename
    field_suffix_expression
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

  class NotSupportedError < StandardError; end
end