$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))


require 'piglet'
require 'spec'
require 'spec/autorun'


require 'piglet/interpreter'

Spec::Runner.configure do |config|
  
end
