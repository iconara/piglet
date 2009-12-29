require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe Piglet::Interpreter do

  before do
    @interpreter = Piglet::Interpreter.new
  end

  it 'interprets a block given to #new' do
    output = Piglet::Interpreter.new { store(load('some/path'), 'out') }
    output.to_pig_latin.should include("LOAD 'some/path'")
  end
  
  it 'interprets a block given to #interpret' do
    output = @interpreter.interpret { store(load('some/path'), 'out') }
    output.to_pig_latin.should include("LOAD 'some/path'")
  end

  it 'does nothing with no commands' do
    @interpreter.interpret.to_pig_latin.should == ''
  end
    
  describe 'LOAD' do
    it 'constructs a LOAD statement without a USING clause if none specified' do
      @interpreter.interpret { store(load('some/path'), 'out') }
      @interpreter.to_pig_latin.should_not include('USING')
    end
  
    it 'constructs a LOAD statement with a USING clause with a specified method' do
      @interpreter.interpret { store(load('some/path', :using => 'XYZ'), 'out') }
      @interpreter.to_pig_latin.should include("LOAD 'some/path' USING XYZ;")
    end
  
    it 'knows that the load method :pig_storage means PigStorage' do
      @interpreter.interpret { store(load('some/path', :using => :pig_storage), 'out') }
      @interpreter.to_pig_latin.should include("LOAD 'some/path' USING PigStorage;")
    end
  
    it 'constructs a LOAD statement with an AS clause' do
      @interpreter.interpret { store(load('some/path', :schema => %w(a b c)), 'out') }
      @interpreter.to_pig_latin.should include("LOAD 'some/path' AS (a, b, c);")
    end
  
    it 'constructs a LOAD statement with an AS clause with types' do
      @interpreter.interpret { store(load('some/path', :schema => [:a, [:b, :chararray], :c]), 'out') }
      @interpreter.to_pig_latin.should include("LOAD 'some/path' AS (a, b:chararray, c);")
    end
  
    it 'constructs a LOAD statement with an AS clause with types specified as both strings and symbols' do
      @interpreter.interpret { store(load('some/path', :schema => [:a, %w(b chararray), :c]), 'out') }
      @interpreter.to_pig_latin.should include("LOAD 'some/path' AS (a, b:chararray, c);")
    end
  end
  
end
