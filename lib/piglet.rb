module Piglet
  autoload_files = %w(
    assignment
    cross
    describe
    distinct
    dump
    explain
    field
    field_expression
    field_expression_functions
    field_infix_expression
    field_rename
    filter
    foreach
    group
    illustrate
    interpreter
    limit
    load_and_store
    load
    relation
    sample
    split
    store
    storing
    union
  )
  
  autoload_files.each do |f|
    c = f.split('_').map { |s| s.capitalize }.join.to_sym
    p = "piglet/#{f}"
    autoload c, p
  end

  class NotSupportedError < StandardError; end
end