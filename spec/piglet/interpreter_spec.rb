require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe Piglet::Interpreter do

  before do
    @interpreter = Piglet::Interpreter.new
  end

  it 'interprets a block given to #new' do
    Piglet::Interpreter.new { load('some/path') }.to_pig_latin.should eql("LOAD 'some/path';")
  end
  
  it 'interprets a block given to #interpret' do
    @interpreter.interpret { load('some/path') }.to_pig_latin.should eql("LOAD 'some/path';")
  end

  it 'does nothing with no commands' do
    @interpreter.interpret.to_pig_latin.should == ''
  end

  context 'load' do
    it 'constructs a LOAD statement' do
      @interpreter.interpret { load('some/path') }
      @interpreter.to_pig_latin.should eql(%{LOAD 'some/path';})
    end
    
    it 'constructs a LOAD statement without a USING clause if none specified' do
      @interpreter.interpret { load('some/path') }
      @interpreter.to_pig_latin.should_not include('USING')
    end
    
    it 'constructs a LOAD statement with a USING clause with a specified method' do
      @interpreter.interpret { load('some/path').using('Test') }
      @interpreter.to_pig_latin.should eql(%{LOAD 'some/path' USING Test;})
    end
    
    it 'knows that the load method :pig_storage means PigStorage' do
      @interpreter.interpret { load('some/path').using(:pig_storage) }
      @interpreter.to_pig_latin.should eql(%{LOAD 'some/path' USING PigStorage;})
    end
    
    it 'constructs a LOAD statement with an AS clause' do
      @interpreter.interpret { load('some/path').as(:a, :b, :c) }
      @interpreter.to_pig_latin.should eql(%{LOAD 'some/path' AS (a, b, c);})
    end
    
    it 'constructs a LOAD statement with an AS clause with types' do
      @interpreter.interpret { load('some/path').as(:a, [:b, :chararray], :c) }
      @interpreter.to_pig_latin.should eql(%{LOAD 'some/path' AS (a, b:chararray, c);})
    end
    
    it 'constructs a LOAD statement with an AS clause with types specified as both strings and symbols' do
      @interpreter.interpret { load('some/path').as(:a, %w(b chararray), :c) }
      @interpreter.to_pig_latin.should eql(%{LOAD 'some/path' AS (a, b:chararray, c);})
    end
  end
  
  context 'multiple statements' do
    it 'constructs each statement and output them on separate lines' do
      @interpreter.interpret do
        load('some/path')
        load('some/other/path')
      end
      @interpreter.to_pig_latin.should eql(%{LOAD 'some/path';\nLOAD 'some/other/path';})
    end
  end
  
  context 'relations as variables' do
    it 'can store a relation in a variable' do
      @interpreter.interpret { a << load('some/path') }
      @interpreter.to_pig_latin.should eql(%{a = LOAD 'some/path';})
    end
  end

end
