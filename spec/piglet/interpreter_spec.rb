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
    
  context 'load & store operators:' do
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
  
      Piglet::LoadAndStore::LOAD_STORE_FUNCTIONS.each do |symbolic_name, function|
        it "knows that the load method :#{symbolic_name} means #{function}" do
          @interpreter.interpret { store(load('some/path', :using => symbolic_name), 'out') }
          @interpreter.to_pig_latin.should include("LOAD 'some/path' USING #{function};")
        end
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
  end
  
  context 'diagnostic operators:' do
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
  end
  
  context 'relation operators:' do
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

    describe 'CROSS' do
      it 'outputs a CROSS statement with two relations' do
        @interpreter.interpret do
          a = load('in1')
          b = load('in2')
          c = a.cross(b)
          dump(c)
        end
        @interpreter.to_pig_latin.should match(/CROSS \w+, \w+/)
      end
      
      it 'outputs a CROSS statement with many relations' do
        @interpreter.interpret do
          a = load('in1')
          b = load('in2')
          c = load('in3')
          d = load('in4')
          e = a.cross(b, c, d)
          dump(e)
        end
        @interpreter.to_pig_latin.should match(/CROSS \w+, \w+, \w+, \w+/)
      end
      
      it 'outputs a CROSS statement with a PARALLEL clause' do
        @interpreter.interpret do
          a = load('in1')
          b = load('in2')
          c = load('in3')
          d = a.cross([b, c], :parallel => 4)
          dump(d)
        end
        @interpreter.to_pig_latin.should match(/CROSS \w+, \w+, \w+ PARALLEL 4/)
      end
    end

    describe 'UNION' do
      it 'outputs a UNION statement with two relations' do
        @interpreter.interpret do
          a = load('in1')
          b = load('in2')
          c = a.union(b)
          dump(c)
        end
        @interpreter.to_pig_latin.should match(/UNION \w+, \w+/)
      end
      
      it 'outputs a UNION statement with many relations' do
        @interpreter.interpret do
          a = load('in1')
          b = load('in2')
          c = load('in3')
          d = load('in4')
          e = a.union(b, c, d)
          dump(e)
        end
        @interpreter.to_pig_latin.should match(/UNION \w+, \w+, \w+, \w+/)
      end
    end
    
    describe 'SAMPLE' do
      it 'outputs a SAMPLE statement' do
        @interpreter.interpret { dump(load('in').sample(10)) }
        @interpreter.to_pig_latin.should match(/SAMPLE \w+ 10/)
      end
    end

    describe 'LIMIT' do
      it 'outputs a LIMIT statement' do
        @interpreter.interpret { dump(load('in').limit(42)) }
        @interpreter.to_pig_latin.should match(/LIMIT \w+ 42/)
      end
    end

    describe 'FOREACH … GENERATE' do
      it 'outputs a FOREACH … GENERATE statement' do
        @interpreter.interpret { dump(load('in').foreach { |r| :a }) }
        @interpreter.to_pig_latin.should match(/FOREACH \w+ GENERATE a/)
      end
      
      it 'outputs a FOREACH … GENERATE statement with a list of fields' do
        @interpreter.interpret { dump(load('in').foreach { |r| [:a, :b, :c] }) }
        @interpreter.to_pig_latin.should match(/FOREACH \w+ GENERATE a, b, c/)
      end
      
      it 'outputs a FOREACH … GENERATE statement with fields resolved from the relation' do
        @interpreter.interpret { dump(load('in').foreach { |r| [r.a, r.b, r.c] }) }
        @interpreter.to_pig_latin.should match(/FOREACH (\w+) GENERATE a, b, c/)
      end
      
      it 'outputs a FOREACH … GENERATE statement with fields resolved from the relation with positional syntax' do
        @interpreter.interpret { dump(load('in').foreach { |r| [r[0], r[1], r[2]] }) }
        @interpreter.to_pig_latin.should match(/FOREACH (\w+) GENERATE \$0, \$1, \$2/)
      end
      
      it 'outputs a FOREACH … GENERATE statement with aggregate functions applied to the fields' do
        @interpreter.interpret { dump(load('in').foreach { |r| [r.a.max, r.b.min, r.c.avg] }) }
        @interpreter.to_pig_latin.should match(/FOREACH (\w+) GENERATE MAX\(a\), MIN\(b\), AVG\(c\)/)
      end
      
      it 'outputs a FOREACH … GENERATE statement with fields that access inner fields' do
        @interpreter.interpret { dump(load('in').foreach { |r| [r.a.b, r.b.c, r.c.d] }) }
        @interpreter.to_pig_latin.should match(/FOREACH (\w+) GENERATE a.b, b.c, c.d/)
      end
      
      it 'outputs a FOREACH … GENERATE statement that includes field aliasing' do
        @interpreter.interpret { dump(load('in').foreach { |r| [r.a.b.as(:c), r.a.b.as(:d)] }) }
        @interpreter.to_pig_latin.should match(/FOREACH (\w+) GENERATE a.b AS c, a.b AS d/)
      end
    end

    describe 'FILTER' do
      it 'outputs a FILTER statement' do
        @interpreter.interpret { dump(load('in').filter { |r| r.a == 3 }) }
        @interpreter.to_pig_latin.should match(/FILTER \w+ BY a == 3/)
      end

      # it 'outputs a FILTER statement with a complex test' do
      #   @interpreter.interpret { dump(load('in').filter { |r| r.a > r.b && r.c != 3 }) }
      #   @interpreter.to_pig_latin.should match(/FILTER \w+ BY a > b AND c != 3/)
      # end
    end
    
    describe 'SPLIT' do
      it 'outputs a SPLIT statement' do
        @interpreter.interpret do
          a, b = load('in').split { |r| [r.a >= 0, r.a < 0]}
          dump(a)
          dump(b)
        end
        @interpreter.to_pig_latin.should match(/SPLIT \w+ INTO \w+ IF a >= 0, \w+ IF a < 0/)
      end
    end
    
    describe 'ORDER' do
      it 'outputs an ORDER statement' do
        @interpreter.interpret { dump(load('in').order(:a)) }
        @interpreter.to_pig_latin.should match(/ORDER \w+ BY a/)
      end
      
      it 'outputs an ORDER statement with multiple fields' do
        @interpreter.interpret { dump(load('in').order(:a, :b)) }
        @interpreter.to_pig_latin.should match(/ORDER \w+ BY a, b/)
      end
      
      it 'outputs an ORDER statement with ASC and DESC' do
        @interpreter.interpret { dump(load('in').order([:a, :asc], [:b, :desc])) }
        @interpreter.to_pig_latin.should match(/ORDER \w+ BY a ASC, b DESC/)
      end
    end
    
    describe 'JOIN' do
      it 'outputs a JOIN statement' do
        @interpreter.interpret do
          a = load('in1')
          b = load('in2')
          c = a.join(a => :x, b => :y)
          dump(c)
        end
        @interpreter.to_pig_latin.should match(/JOIN \w+ BY \w+, \w+ BY \w+/)
      end

      it 'outputs a JOIN statement with a PARALLEL clause' do
        @interpreter.interpret do
          a = load('in1')
          b = load('in2')
          c = a.join(a => :x, b => :y, :parallel => 5)
          dump(c)
        end
        @interpreter.to_pig_latin.should match(/JOIN \w+ BY \w+, \w+ BY \w+ PARALLEL 5/)
      end

      it 'outputs a JOIN statement with a USING clause' do
        @interpreter.interpret do
          a = load('in1')
          b = load('in2')
          c = a.join(a => :x, b => :y, :using => :replicated)
          dump(c)
        end
        @interpreter.to_pig_latin.should match(/JOIN \w+ BY \w+, \w+ BY \w+ USING "replicated"/)
      end
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

end
