# encoding: utf-8

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))


require 'piglet'
require 'spec'
require 'spec/autorun'


class PlainRelation
  include Piglet::Relation::Relation
  
  def initialize(interpreter)
    @interpreter = interpreter
  end
end


Spec::Runner.configure do |config|
  
end
