module Piglet
  autoload :Interpreter, 'piglet/interpreter'
  
  class NotSupportedError < StandardError; end
end