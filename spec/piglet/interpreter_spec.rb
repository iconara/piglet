require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe Piglet::Interpreter do

  before do
    @interpreter = Piglet::Interpreter.new
  end

  context 'basic usage' do
    it 'interprets a block given to #new' do
      output = Piglet::Interpreter.new { store(load('some/path'), 'out') }
      output.to_pig_latin.should_not be_empty
    end
  
    it 'interprets a block given to #interpret' do
      output = @interpreter.interpret { store(load('some/path'), 'out') }
      output.to_pig_latin.should_not be_empty
    end

    it 'does nothing with no commands' do
      @interpreter.interpret.to_pig_latin.should be_empty
    end
  end
    
  describe '#test' do
    it 'outputs a binary conditional' do
      @interpreter.interpret do
        dump(load('in').foreach { |r| [test(r.a == r.b, r.a, r.b)]})
      end
      @interpreter.to_pig_latin.should include('(a == b ? a : b)')
    end
  end

  describe '#literal' do
    it 'outputs a literal string' do
      @interpreter.interpret do
        dump(load('in').foreach { |r| [literal('hello').as(:world)]})
      end
      @interpreter.to_pig_latin.should include("'hello' AS world")
    end
    
    it 'outputs a literal integer' do
      @interpreter.interpret do
        dump(load('in').foreach { |r| [literal(3).as(:n)]})
      end
      @interpreter.to_pig_latin.should include("3 AS n")
    end
    
    it 'outputs a literal float' do
      @interpreter.interpret do
        dump(load('in').foreach { |r| [literal(3.14).as(:pi)]})
      end
      @interpreter.to_pig_latin.should include("3.14 AS pi")
    end
    
    it 'outputs a literal string when passed an arbitrary object' do
      @interpreter.interpret do
        dump(load('in').foreach { |r| [literal(self).as(:interpreter)]})
      end
      @interpreter.to_pig_latin.should match(/'[^']+' AS interpreter/)
    end
    
    it 'escapes single quotes' do
      @interpreter.interpret do
        dump(load('in').foreach { |r| [literal("hello 'world'").as(:str)]})
      end
      @interpreter.to_pig_latin.should include("'hello \\'world\\'' AS str")
    end
  end

end
