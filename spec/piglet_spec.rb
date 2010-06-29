# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')


describe Piglet do

  before do
    @interpreter = Piglet::Interpreter.new
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
  
      Piglet::Inout::StorageTypes::LOAD_STORE_FUNCTIONS.each do |symbolic_name, function|
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

  context 'parameter declarations:' do
    %w(declare default).each do |op|
      describe "%#{op}" do
        it "outputs a %#{op} statement" do
          @interpreter.interpret { self.send(op, :my_var, 'my_value') }
          @interpreter.to_pig_latin.should match(/%#{op} my_var 'my_value'/)
        end
      
        it "outputs a %#{op} statement with single quotes escaped" do
          @interpreter.interpret { self.send(op, :my_var, "my 'value'") }
          @interpreter.to_pig_latin.should match(/%#{op} my_var 'my \\'value\\''/)
        end

        it "outputs a %#{op} statement with an numeric value unquoted" do
          @interpreter.interpret { self.send(op, :my_var, 1) }
          @interpreter.to_pig_latin.should match(/%#{op} my_var 1/)
        end

        it "outputs a %#{op} statement with an symbol value quoted" do
          @interpreter.interpret { self.send(op, :my_var, :x) }
          @interpreter.to_pig_latin.should match(/%#{op} my_var 'x'/)
        end

        it "outputs a %#{op} statement with the value quoted in backticks, if the option :backticks => true is passed" do
          @interpreter.interpret { self.send(op, :my_var, 'cut -f 4', :backticks => true) }
          @interpreter.to_pig_latin.should match(/%#{op} my_var `cut -f 4`/)
        end
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
        @interpreter.interpret { dump(load('in').foreach { :a }) }
        @interpreter.to_pig_latin.should match(/FOREACH \w+ GENERATE a/)
      end
      
      it 'outputs a FOREACH … GENERATE statement with a list of fields' do
        @interpreter.interpret { dump(load('in').foreach { [:a, :b, :c] }) }
        @interpreter.to_pig_latin.should match(/FOREACH \w+ GENERATE a, b, c/)
      end
      
      it 'outputs a FOREACH … GENERATE statement with fields resolved from the relation' do
        @interpreter.interpret { dump(load('in').foreach { [a, b, c] }) }
        @interpreter.to_pig_latin.should match(/FOREACH (\w+) GENERATE a, b, c/)
      end
      
      it 'outputs a FOREACH … GENERATE statement with fields resolved from the relation with positional syntax' do
        @interpreter.interpret { dump(load('in').foreach { [self[0], self[1], self[2]] }) }
        @interpreter.to_pig_latin.should match(/FOREACH (\w+) GENERATE \$0, \$1, \$2/)
      end
      
      it 'outputs a FOREACH … GENERATE statement with aggregate functions applied to the fields' do
        @interpreter.interpret { dump(load('in').foreach { [a.max, b.min, c.avg] }) }
        @interpreter.to_pig_latin.should match(/FOREACH (\w+) GENERATE MAX\(a\), MIN\(b\), AVG\(c\)/)
      end
      
      it 'outputs a FOREACH … GENERATE statement with fields that access inner fields' do
        @interpreter.interpret { dump(load('in').foreach { [a.b, b.c, c.d] }) }
        @interpreter.to_pig_latin.should match(/FOREACH (\w+) GENERATE a.b, b.c, c.d/)
      end
      
      it 'outputs a FOREACH … GENERATE statement that includes field aliasing' do
        @interpreter.interpret { dump(load('in').foreach { [a.b.as(:c), a.b.as(:d)] }) }
        @interpreter.to_pig_latin.should match(/FOREACH (\w+) GENERATE a.b AS c, a.b AS d/)
      end
    end
    
    describe 'FOREACH ... { ... GENERATE }' do
      it 'outputs a FOREACH ... { ... GENERATE } statement for named fields' do
        @interpreter.interpret { dump(load('in').nested_foreach { [a, b, c] }) }
        @interpreter.to_pig_latin.should match(/FOREACH (\w+) \{\s+field_1 = a;\s+field_2 = b;\s+field_3 = c;\s+GENERATE field_1,field_2,field_3;\s+\}/m)
      end      
      
      it 'outputs a FOREACH ... { ... GENERATE } statement for positional fields' do
        @interpreter.interpret { dump(load('in').nested_foreach { [self[0], self[1], self[2]] }) }
        @interpreter.to_pig_latin.should match(/FOREACH (\w+) \{\s+field_4 = \$0\;\s+field_5 = \$1\;\s+field_6 = \$2\;\s+GENERATE field_4,field_5,field_6\;\s+\}/m)
      end
      
      it 'outputs a FOREACH ... { ... GENERATE } statement with aggregate functions applied to fields' do
        @interpreter.interpret { dump(load('in').nested_foreach { [a.max, b.min, c.avg] }) }
        @interpreter.to_pig_latin.should match(/FOREACH (\w+) \{\s+field_7 = a;\s+field_8 = MAX\(field_7\);\s+field_9 = b;\s+field_10 = MIN\(field_9\);\s+field_11 = c;\s+field_12 = AVG\(field_11\);\s+GENERATE field_8,field_10,field_12;\s+\}/m)
      end
      
      it 'outputs a FOREACH ... { ... GENERATE } statement with fields that access inner fields' do
        @interpreter.interpret { dump(load('in').nested_foreach { [a.b, b.c]}) }
        @interpreter.to_pig_latin.should match (/FOREACH (\w+) \{\s+field_13 = a;\s+field_14 = field_13.b;\s+field_15 = b;\s+field_16 = field_15.c;\s+GENERATE field_14,field_16;\s+\}/m)
      end
      
      it 'outputs a FOREACH ... { ... GENERATE } statement with user defined functions' do
        @interpreter.interpret do 
          define('my_udf', :function => 'com.example.My')
          dump(load('in').nested_foreach { [my_udf(a, 3, "hello")] })
        end
        @interpreter.to_pig_latin.should match (/FOREACH (\w+) \{\s+field_17 = a;\s+field_18 = my_udf\(field_17, 3, 'hello'\);\s+GENERATE field_18;\s+\}/)
      end
      
      it 'outputs a FOREACH ... { ... GENERATE } statement with bag methods' do
        @interpreter.interpret { dump(load('in').nested_foreach { [self[1].distinct.sample(0.3).limit(5).order(:x).filter { x == 5 }] }) }
        @interpreter.to_pig_latin.should match (/FOREACH (\w+) \{\s+field_19 = \$1;\s+field_20 = DISTINCT field_19;\s+field_21 = SAMPLE field_20 0.3;\s+field_22 = LIMIT field_21 5;\s+field_23 = ORDER field_22 BY x;\s+field_24 = FILTER field_23 BY x == 5;\s+GENERATE field_24;\s+\}/m)
      end
      
      it 'outputs a FOREACH ... { ... GENERATE } statement with field aliasing'
    end

    describe 'FILTER' do
      it 'outputs a FILTER statement' do
        @interpreter.interpret { dump(load('in').filter { a == 3 }) }
        @interpreter.to_pig_latin.should match(/FILTER \w+ BY a == 3/)
      end

      it 'outputs a FILTER statement with a complex test' do
        @interpreter.interpret { dump(load('in').filter { (a > b).and(c.ne(3)) }) }
        @interpreter.to_pig_latin.should match(/FILTER \w+ BY \(a > b\) AND \(c != 3\)/)
      end
    end
    
    describe 'SPLIT' do
      it 'outputs a SPLIT statement' do
        @interpreter.interpret do
          a, b = load('in').split { [first >= 0, second < 0] }
          dump(a)
          dump(b)
        end
        @interpreter.to_pig_latin.should match(/SPLIT \w+ INTO \w+ IF first >= 0, \w+ IF second < 0/)
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
    
    describe 'COGROUP' do
      it 'outputs a COGROUP statement' do
        @interpreter.interpret do
          a = load('in1')
          b = load('in2')
          c = a.cogroup(a => :x, b => :y)
          dump(c)
        end
        @interpreter.to_pig_latin.should match(/COGROUP \w+ BY \w+, \w+ BY \w+/)
      end
      
      it 'outputs a COGROUP statement with multiple join fields' do
        @interpreter.interpret do
          a = load('in1')
          b = load('in2')
          c = a.cogroup(a => :x, b => [:y, :z, :w])
          dump(c)
        end
        @interpreter.to_pig_latin.should match(/\w+ BY \(y, z, w\)/)
      end

      it 'outputs a COGROUP statement with a PARALLEL clause' do
        @interpreter.interpret do
          a = load('in1')
          b = load('in2')
          c = a.cogroup(a => :x, b => :y, :parallel => 5)
          dump(c)
        end
        @interpreter.to_pig_latin.should match(/COGROUP \w+ BY \w+, \w+ BY \w+ PARALLEL 5/)
      end
      
      it 'outputs a COGROUP statement with INNER and OUTER' do
        @interpreter.interpret do
          a = load('in1')
          b = load('in2')
          c = a.cogroup(a => [:x, :inner], b => [:y, :outer])
          dump(c)
        end
        @interpreter.to_pig_latin.should match(/\w+ BY x INNER/)
        @interpreter.to_pig_latin.should match(/\w+ BY y OUTER/)
      end
    end
    
    describe 'STREAM' do
      it 'outputs a STREAM statement with a command reference' do
        output = @interpreter.to_pig_latin do
          a = load('in')
          b = a.stream(:swoosch)
          store(b, 'out')
        end
        output.should match(/STREAM \w+ THROUGH swoosch/)
      end

      it 'outputs a STREAM statement with a command' do
        output = @interpreter.to_pig_latin do
          a = load('in')
          b = a.stream(:command => 'swoosch')
          store(b, 'out')
        end
        output.should match(/STREAM \w+ THROUGH `swoosch`/)
      end

      it 'outputs a STREAM statement with a schema' do
        output = @interpreter.to_pig_latin do
          a = load('in')
          b = a.stream(:command => 'swoosch', :schema => [:a, :b])
          store(b, 'out')
        end
        output.should match(/STREAM \w+ THROUGH `swoosch` AS \(a:bytearray, b:bytearray\)/)
      end
      
      it 'outputs a STREAM statement with many relations' do
        output = @interpreter.to_pig_latin do
          x = load('in1')
          y = load('in2')
          z = load('in3')
          w = x.stream([x, y], :plink)
          store(w, 'out')
        end
        output.should match(/STREAM \w+, \w+, \w+ THROUGH plink/)
      end
    end
  end

  context 'UDF statements:' do
    describe 'DEFINE' do
      it 'outputs a DEFINE with the correct alias and function name' do
        output = @interpreter.to_pig_latin { define('plunk', :function => 'com.example.Plunk') }
        output.should include('DEFINE plunk com.example.Plunk')
      end
      
      it 'outputs a DEFINE with the correct alias and command string' do
        output = @interpreter.to_pig_latin { define('plunk', :command => 'plunk.rb') }
        output.should include('DEFINE plunk `plunk.rb`')
      end

      it 'outputs a DEFINE with an INPUT definition' do
        output = @interpreter.to_pig_latin do
          define('plunk', :command => 'plunk.rb', :input => :stdin)
        end
        output.should include('DEFINE plunk `plunk.rb` INPUT(stdin)')
      end

      it 'outputs a DEFINE with an OUTPUT definition' do
        output = @interpreter.to_pig_latin do
          define('plunk', :command => 'plunk.rb', :output => :stdout)
        end
        output.should include('DEFINE plunk `plunk.rb` OUTPUT(stdout)')
      end

      it 'outputs a DEFINE with a SHIP definition with one path' do
        output = @interpreter.to_pig_latin do
          define('plunk', :command => 'plunk.rb', :ship => 'path/to/somewhere')
        end
        output.should include('DEFINE plunk `plunk.rb` SHIP(\'path/to/somewhere\')')
      end

      it 'outputs a DEFINE with a SHIP definition with may paths' do
        output = @interpreter.to_pig_latin do
          define('plunk', :command => 'plunk.rb', :ship => ['path/to/somewhere', 'and/to/somewhere/else'])
        end
        output.should include('DEFINE plunk `plunk.rb` SHIP(\'path/to/somewhere\', \'and/to/somewhere/else\')')
      end

      it 'outputs a DEFINE with a CACHE definition with one path description' do
        output = @interpreter.to_pig_latin do
          define('plunk', :command => 'plunk.rb', :cache => '/input/data.gz#data.gz')
        end
        output.should include('DEFINE plunk `plunk.rb` CACHE(\'/input/data.gz#data.gz\')')
      end

      it 'outputs a DEFINE with a CACHE definition with may path descriptions' do
        output = @interpreter.to_pig_latin do
          define('plunk', :command => 'plunk.rb', :cache => ['/input/data.gz#data.gz', '/mydir/mydata.txt#mydata.txt'])
        end
        output.should include('DEFINE plunk `plunk.rb` CACHE(\'/input/data.gz#data.gz\', \'/mydir/mydata.txt#mydata.txt\')')
      end

      it 'outputs a DEFINE with with a somewhat complex INPUT definition' do
        output = @interpreter.to_pig_latin do
          define('plunk', :command => 'plunk.rb', :input => {:from => 'some/path', :using => :pig_storage})
        end
        output.should include('DEFINE plunk `plunk.rb` INPUT(\'some/path\' USING PigStorage)')
      end

      it 'outputs a DEFINE with with really complex options' do
        output = @interpreter.to_pig_latin do
          define('plunk', :command => 'plunk.rb', 
            :input => [
              {:from => 'some/path', :using => :pig_storage},
              {:from => :stdin, :using => 'HelloWorld(\'test\')'}
            ],
            :output => [
              {:to => 'some/other/path', :using => :bin_storage},
              {:to => :stdout, :using => 'SomeOtherMechanism()'}
            ],
            :ship => 'to/here',
            :cache => ['first', 'second', 'third']
          )
        end
        output.should include('DEFINE plunk `plunk.rb` INPUT(\'some/path\' USING PigStorage, stdin USING HelloWorld(\'test\')) OUTPUT(\'some/other/path\' USING BinStorage, stdout USING SomeOtherMechanism()) SHIP(\'to/here\') CACHE(\'first\', \'second\', \'third\')')
      end
      
      it 'makes the defined UDF available as a method in the interpreter scope, so that it can be used in a FOREACH and it\'s result renamed using AS' do
        output = @interpreter.to_pig_latin do
          define('my_udf', :function => 'com.example.My')
          a = load('in')
          b = a.foreach { [my_udf('foo', 3, 'hello \'world\'', self[0]).as(:bar)]}
          store(b, 'out')
        end
        output.should match(/FOREACH \w+ GENERATE my_udf\('foo', 3, 'hello \\'world\\'', \$0\) AS bar/)
      end
    end
    
    describe 'REGISTER' do
      it 'outputs a REGISTER statement with the path to the specified JAR' do
        output = @interpreter.to_pig_latin { register('path/to/lib.jar') }
        output.should include('REGISTER path/to/lib.jar')
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

  context 'field expressions' do
    it 'parenthesizes expressions with different operators' do
      output = @interpreter.to_pig_latin do
        store(load('in').filter { self.x.and(self.y.or(self.z)).and(self.w) }, 'out')
      end
      output.should include('x AND (y OR z) AND w')
    end
    
    it 'doesn\'t parenthesizes expressions with the same operator' do
      output = @interpreter.to_pig_latin do
        store(load('in').filter { self.x.and(self.y.and(self.z)).and(self.w) }, 'out')
      end
      output.should include('x AND y AND z AND w')
    end

    it 'doesn\'t parenthesize function calls' do
      output = @interpreter.to_pig_latin do
        store(load('in').foreach { [self.x.max + self.y.min] }, 'out')
      end
      output.should include('MAX(x) + MIN(y)')
    end

    it 'doesn\'t parenthesize a suffix expression followed by an infix expression' do
      output = @interpreter.to_pig_latin do
        store(load('in').foreach { [self.x.null?.or(self.y)] }, 'out')
      end
      output.should include('x is null OR y')
    end

    it 'parenthesizes a prefix expression followed by an infix expression' do
      output = @interpreter.to_pig_latin do
        store(load('in').foreach { [self.x.not.and(self.y)] }, 'out')
      end
      output.should include('(NOT x) AND y')
    end
  end
  
  context 'long and complex scripts' do
    before do
      @interpreter.interpret do
        sessions = load('sessions', :schema => [
          [:ad_id, :chararray],
          [:site, :chararray],
          [:size, :chararray],
          [:name, :chararray],
          [:impression, :int],
          [:engagement, :int],
          [:click_thru, :int]
        ])
        %w(site size name).each do |dimension|
          result = sessions.group(:ad_id, dimension).foreach do
            [
              self[0].ad_id.as(:ad_id),
              literal(dimension).as(:dimension),
              self[0].field(dimension).as(:value),
              self[1].exposure.sum.as(:exposures),
              self[1].impression.sum.as(:impressions),
              self[1].engagement.sum.as(:engagements),
              self[1].click_thru.sum.as(:click_thrus)
            ]
          end
          store(result, "report_metrics-#{dimension}")
        end
      end
      @output = @interpreter.to_pig_latin
    end

    it 'outputs the correct number of LOAD statements' do
      @output.scan(/LOAD/).size.should eql(1)
    end
    
    it 'outputs the correct number of STORE statements' do
      @output.scan(/STORE/).size.should eql(3)
    end

    it 'doesn\'t assign to the same relation twice' do
      @assignments = @output.scan(/^(\w+)(?=\s*=)/).flatten
      @assignments.uniq.should eql(@assignments)
    end
  end

  context 'schemas' do
    it 'knows the schema of a relation returned by #load, with types' do
      schema = catch(:schema) do
        @interpreter.interpret do
          schema = load('in', :schema => [[:a, :chararray], [:b, :chararray]]).schema
          throw :schema, schema
        end
      end
      schema.field_names.should eql([:a, :b])
      schema.field_type(:a).should eql(:chararray)
    end
    
    it 'knows the schema of a relation returned by #load, without types' do
      schema = catch(:schema) do
        @interpreter.interpret do
          schema = load('in', :schema => [:a, :b]).schema
          throw :schema, schema
        end
      end
      schema.field_names.should eql([:a, :b])
      schema.field_type(:a).should eql(:bytearray)
    end
    
    it 'knows the schema of a relation returned by #load, with and without types' do
      schema = catch(:schema) do
        @interpreter.interpret do
          schema = load('in', :schema => [[:a, :float], :b]).schema
          throw :schema, schema
        end
      end
      schema.field_names.should eql([:a, :b])
      schema.field_type(:a).should eql(:float)
    end
    
    it 'does not know anything about the schema of a relation returned by #load if no schema was given' do
      relation = catch(:relation) do
        @interpreter.interpret do
          throw :relation, load('in')
        end
      end
      relation.schema.should be_nil
    end
    
    it 'knows the schema of a relation derived through non-schema-changing operations' do
      schema = catch(:schema) do
        @interpreter.interpret do
          relation = load('in', :schema => [[:a, :float], [:b, :int]]).limit(3).sample(0.1).distinct.order(:a)
          throw :schema, relation.schema
        end
      end
      schema.field_names.should eql([:a, :b])
      schema.field_type(:a).should eql(:float)
      schema.field_type(:b).should eql(:int)
    end
    
    it 'knows the schema of a relation grouped on one field' do
      relation = catch(:relation) do
        @interpreter.interpret do
          relation = load('in', :schema => [[:a, :float], [:b, :int]]).group(:a)
          throw :relation, relation
        end
      end
      source_relation_name = relation.sources.first.alias.to_sym
      relation.schema.field_names.should eql([:group, source_relation_name])
      relation.schema.field_type(:group).should eql(:float)
      relation.schema.field_type(source_relation_name).should be_a(Piglet::Schema::Bag)
      relation.schema.field_type(source_relation_name).field_names.should eql([:a, :b])
      relation.schema.field_type(source_relation_name).field_type(:a).should eql(:float)
    end

    it 'knows the schema of a relation grouped on more than one field' do
      relation = catch(:relation) do
        @interpreter.interpret do
          relation = load('in', :schema => [[:a, :float], [:b, :int]]).group(:a, :b)
          throw :relation, relation
        end
      end
      source_relation_name = relation.sources.first.alias.to_sym
      relation.schema.field_names.should eql([:group, source_relation_name])
      relation.schema.field_type(:group).should be_a(Piglet::Schema::Tuple)
      relation.schema.field_type(:group).field_names.should eql([:a, :b])
      relation.schema.field_type(:group).field_type(:a).should eql(:float)
      relation.schema.field_type(source_relation_name).should be_a(Piglet::Schema::Bag)
      relation.schema.field_type(source_relation_name).field_names.should eql([:a, :b])
      relation.schema.field_type(source_relation_name).field_type(:b).should eql(:int)
    end

    it 'knows the schema of a relation cross joined with itself' do
      schema = catch(:schema) do
        @interpreter.interpret do
          relation = load('in', :schema => [[:a, :float], [:b, :int]])
          relation = relation.cross(relation)
          throw :schema, relation.schema
        end
      end
      schema.field_names.should eql([:a, :b, :a, :b])
      schema.field_type(:a).should eql(:float)
      schema.field_type(:b).should eql(:int)
    end
    
    it 'knows the schema of a relation cross joined with another' do
      schema = catch(:schema) do
        @interpreter.interpret do
          relation1 = load('in1', :schema => [[:a, :float], [:b, :int]])
          relation2 = load('in2', :schema => [[:c, :chararray], [:d, :double]])
          relation3 = relation1.cross(relation2)
          throw :schema, relation3.schema
        end
      end
      schema.field_names.should eql([:a, :b, :c, :d])
      schema.field_type(:a).should eql(:float)
      schema.field_type(:b).should eql(:int)
      schema.field_type(:c).should eql(:chararray)
      schema.field_type(:d).should eql(:double)
    end

    it 'knows the schema of a relation joined with another' do
      schema = catch(:schema) do
        @interpreter.interpret do
          relation1 = load('in1', :schema => [[:a, :float], [:b, :int]])
          relation2 = load('in2', :schema => [[:c, :int], [:d, :double]])
          relation3 = relation1.join(relation1 => :b, relation2 => :c)
          throw :schema, relation3.schema
        end
      end
      schema.field_names.should eql([:a, :b, :c, :d])
      schema.field_type(:a).should eql(:float)
      schema.field_type(:b).should eql(:int)
      schema.field_type(:c).should eql(:int)
      schema.field_type(:d).should eql(:double)
    end

    it 'knows the schema of a relation cogrouped with another' do
      relation1, relation2, relation3 = catch(:relations) do
        @interpreter.interpret do
          relation1 = load('in1', :schema => [[:a, :float], [:b, :int]])
          relation2 = load('in2', :schema => [[:c, :int], [:d, :double]])
          relation3 = relation1.cogroup(relation1 => :b, relation2 => :c)
          throw :relations, [relation1, relation2, relation3]
        end
      end
      relation3.schema.field_names[0].should eql(:group)
      relation3.schema.field_names.should include(relation1.alias.to_sym)
      relation3.schema.field_names.should include(relation2.alias.to_sym)
      relation3.schema.field_type(relation1.alias.to_sym).should be_a(Piglet::Schema::Bag)
      relation3.schema.field_type(relation2.alias.to_sym).should be_a(Piglet::Schema::Bag)
      relation3.schema.field_type(relation1.alias.to_sym).field_names.should eql([:a, :b])
      relation3.schema.field_type(relation2.alias.to_sym).field_names.should eql([:c, :d])
    end

    it 'knows the schema of a relation projection' do
      schema = catch(:schema) do
        @interpreter.interpret do
          relation1 = load('in1', :schema => [[:a, :float], [:b, :int]])
          relation2 = relation1.foreach { [a] }
          throw :schema, relation2.schema
        end
      end
      schema.field_names.should eql([:a])
      schema.field_type(:a).should eql(:float)
    end
    
    it 'knows the schema of a relation projection containing a call to MAX' do
      schema = catch(:schema) do
        @interpreter.interpret do
          relation1 = load('in1', :schema => [[:a, :float], [:b, :int]])
          relation2 = relation1.foreach { [a.max] }
          throw :schema, relation2.schema
        end
      end
      schema.field_names.should eql([nil])
      schema.field_type(0).should eql(:float)
    end
    
    it 'knows the schema of a relation projection containing a call to COUNT' do
      schema = catch(:schema) do
        @interpreter.interpret do
          relation1 = load('in1', :schema => [[:a, :float], [:b, :int]])
          relation2 = relation1.foreach { [a.count] }
          throw :schema, relation2.schema
        end
      end
      schema.field_names.should eql([nil])
      schema.field_type(0).should eql(:long)
    end
    
    it 'knows the schema of a relation projection containing a field rename' do
      schema = catch(:schema) do
        @interpreter.interpret do
          relation1 = load('in1', :schema => [[:a, :float], [:b, :int]])
          relation2 = relation1.foreach { [a.count.as(:x)] }
          throw :schema, relation2.schema
        end
      end
      schema.field_names.should eql([:x])
    end
    
    it 'knows the schema of a relation projection containing a literal string' do
      schema = catch(:schema) do
        @interpreter.interpret do
          relation1 = load('in1', :schema => [[:a, :float], [:b, :int]])
          relation2 = relation1.foreach { [literal('blipp')] }
          throw :schema, relation2.schema
        end
      end
      schema.field_type(0).should eql(:chararray)
    end
    
    it 'knows the schema of a relation projection containing a literal integer' do
      schema = catch(:schema) do
        @interpreter.interpret do
          relation1 = load('in1', :schema => [[:a, :float], [:b, :int]])
          relation2 = relation1.foreach { [literal(4)] }
          throw :schema, relation2.schema
        end
      end
      schema.field_type(0).should eql(:int)
    end
    
    it 'knows the schema of a relation projection containing a literal float' do
      schema = catch(:schema) do
        @interpreter.interpret do
          relation1 = load('in1', :schema => [[:a, :float], [:b, :int]])
          relation2 = relation1.foreach { [literal(3.14)] }
          throw :schema, relation2.schema
        end
      end
      schema.field_type(0).should eql(:double)
    end
    
    it 'knows the schema of a relation streamed through a command (if there\'s a schema)' do
      schema = catch(:schema) do
        @interpreter.interpret do
          relation1 = load('in1', :schema => [[:a, :float], [:b, :int]])
          relation2 = relation1.stream(:command => 'command', :schema => [[:x, :chararray]])
          throw :schema, relation2.schema
        end
      end
      schema.field_names.should eql([:x])
      schema.field_type(:x).should eql(:chararray)
    end
    
  end

end
