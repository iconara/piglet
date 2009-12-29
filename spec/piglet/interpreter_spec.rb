require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe Piglet::Interpreter do

  before do
    @interpreter = Piglet::Interpreter.new
  end

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
    
  describe 'LOAD' do
    it 'outputs a LOAD statement' do
      @interpreter.interpret { store(load('some/path'), 'out') }
      @interpreter.to_pig_latin.should include("LOAD 'some/path'")
    end
    
    it 'outputs a LOAD statement without a USING clause if none specified' do
      @interpreter.interpret { store(load('some/path'), 'out') }
      @interpreter.to_pig_latin.should_not include('USING')
    end
  
    it 'outputs a LOAD statement with a USING clause with a specified function' do
      @interpreter.interpret { store(load('some/path', :using => 'XYZ'), 'out') }
      @interpreter.to_pig_latin.should include("LOAD 'some/path' USING XYZ;")
    end
  
    it 'knows that the load method :pig_storage means PigStorage' do
      @interpreter.interpret { store(load('some/path', :using => :pig_storage), 'out') }
      @interpreter.to_pig_latin.should include("LOAD 'some/path' USING PigStorage;")
    end
  
    it 'outputs a LOAD statement with an AS clause' do
      @interpreter.interpret { store(load('some/path', :schema => %w(a b c)), 'out') }
      @interpreter.to_pig_latin.should include("LOAD 'some/path' AS (a, b, c);")
    end
  
    it 'outputs a LOAD statement with an AS clause with types' do
      @interpreter.interpret { store(load('some/path', :schema => [:a, [:b, :chararray], :c]), 'out') }
      @interpreter.to_pig_latin.should include("LOAD 'some/path' AS (a, b:chararray, c);")
    end
  
    it 'outputs a LOAD statement with an AS clause with types specified as both strings and symbols' do
      @interpreter.interpret { store(load('some/path', :schema => [:a, %w(b chararray), :c]), 'out') }
      @interpreter.to_pig_latin.should include("LOAD 'some/path' AS (a, b:chararray, c);")
    end
  end

  describe 'STORE' do
    it 'outputs a STORE statement' do
      @interpreter.interpret { store(load('some/path'), 'out') }
      @interpreter.to_pig_latin.should match(/STORE \w+ INTO 'out'/)
    end
    
    it 'outputs a STORE statement without a USING clause if none specified' do
      @interpreter.interpret { store(load('some/path'), 'out') }
      @interpreter.to_pig_latin.should_not include("USING")
    end
    
    it 'outputs a STORE statement with a USING clause with a specified function' do
      @interpreter.interpret { store(load('some/path'), 'out', :using => 'XYZ') }
      @interpreter.to_pig_latin.should match(/STORE \w+ INTO 'out' USING XYZ/)
    end
  
    it 'knows that the load method :pig_storage means PigStorage' do
      @interpreter.interpret { store(load('some/path'), 'out', :using => :pig_storage) }
      @interpreter.to_pig_latin.should match(/STORE \w+ INTO 'out' USING PigStorage/)
    end
  end

  describe 'DUMP' do
    it 'outputs a DUMP statement' do
      @interpreter.interpret { dump(load('some/path')) }
      @interpreter.to_pig_latin.should match(/DUMP \w+/)
    end
  end
  
  describe 'ILLUSTRATE' do
    it 'outputs an ILLUSTRATE statement' do
      @interpreter.interpret { illustrate(load('some/path')) }
      @interpreter.to_pig_latin.should match(/ILLUSTRATE \w+/)
    end
  end
  
  describe 'DESCRIBE' do
    it 'outputs a DESCRIBE statement' do
      @interpreter.interpret { describe(load('some/path')) }
      @interpreter.to_pig_latin.should match(/DESCRIBE \w+/)
    end
  end
  
  describe 'EXPLAIN' do
    it 'outputs an EXPLAIN statement' do
      @interpreter.interpret { explain(load('some/path')) }
      @interpreter.to_pig_latin.should match(/EXPLAIN \w+/)
    end
    
    it 'outputs an EXPLAIN statement without an alias' do
      @interpreter.interpret { explain }
      @interpreter.to_pig_latin.should match(/EXPLAIN;/)
    end
  end

  context 'aliasing & multiple statements' do
    it 'aliases the loaded relation and uses the same alias in the STORE statement' do
      @interpreter.interpret { store(load('in'), 'out') }
      @interpreter.to_pig_latin.should match(/(\w+) = LOAD 'in';\nSTORE \1 INTO 'out';/)
    end
    
    it 'aliases both a loaded relation and a grouped relation and uses the latter in the STORE statement' do
      @interpreter.interpret { store(load('in', :schema => [:a]).group(:a), 'out') }
      @interpreter.to_pig_latin.should match(/(\w+) = LOAD 'in' AS \(a\);\n(\w+) = GROUP \1 BY a;\nSTORE \2 INTO 'out';/)
    end
    
    it 'aliases a whole row of statements' do
      @interpreter.interpret do
        a = load('in', :schema => [:a])
        b = a.group(:a)
        c = b.group(:a)
        d = c.group(:a)
        store(d, 'out')
      end
      @interpreter.to_pig_latin.should match(/(\w+) = LOAD 'in' AS \(a\);\n(\w+) = GROUP \1 BY a;\n(\w+) = GROUP \2 BY a;\n(\w+) = GROUP \3 BY a;\nSTORE \4 INTO 'out';/)
    end
    
    it 'outputs the statements for an alias only once, regardless of home many times it is stored' do
      @interpreter.interpret do
        a = load('in')
        b = a.distinct
        store(b, 'out1')
        store(b, 'out2')
      end
      @interpreter.to_pig_latin.should match(/(\w+) = LOAD 'in';\n(\w+) = DISTINCT \1;\nSTORE \2 INTO 'out1';\nSTORE \2 INTO 'out2';/)
    end
  end

  describe 'GROUP' do
    it 'outputs a GROUP statement with one grouping field' do
      @interpreter.interpret { store(load('in').group(:a), 'out') }
      @interpreter.to_pig_latin.should match(/GROUP \w+ BY a/)
    end
    
    it 'outputs a GROUP statement with more than one grouping field' do
      @interpreter.interpret { store(load('in').group(:a, :b, :c), 'out') }
      @interpreter.to_pig_latin.should match(/GROUP \w+ BY \(a, b, c\)/)
    end
    
    it 'outputs a GROUP statement with a PARALLEL clause' do
      @interpreter.interpret { store(load('in').group([:a, :b, :c], :parallel => 3), 'out') }
      @interpreter.to_pig_latin.should match(/GROUP \w+ BY \(a, b, c\) PARALLEL 3/)
    end
  end
  
  describe 'DISTINCT' do
    it 'outputs a DISTINCT statement' do
      @interpreter.interpret { store(load('in').distinct, 'out') }
      @interpreter.to_pig_latin.should match(/DISTINCT \w+/)
    end
    
    it 'outputs a DISTINCT statement with a PARALLEL clause' do
      @interpreter.interpret { store(load('in').distinct(:parallel => 4), 'out') }
      @interpreter.to_pig_latin.should match(/DISTINCT \w+ PARALLEL 4/)
    end
  end

end
