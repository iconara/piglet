require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')


describe Piglet::Field::Reference do

  before do
    @field = Piglet::Field::Reference.new('field')
  end
  
  describe '#to_s' do
    it 'returns a string with the field name (as a string)' do
      @field.to_s.should eql("field")
    end
    
    it 'returns a string with the field name (as a symbol)' do
      @field = Piglet::Field::Reference.new(:field)
      @field.to_s.should eql("field")
    end
  end

  context 'eval/aggregate functions' do
    %w(avg count max min size sum tokenize).each do |function_name|
      it "supports \"#{function_name.upcase}\" through ##{function_name}" do
        @field.send(function_name).to_s.should eql("#{function_name.upcase}(field)")
      end
    end
  
    it 'supports "IsEmpty" through #empty?' do
      @field.empty?.to_s.should eql("IsEmpty(field)")
    end
  end
  
  context 'nested expressions' do
    it 'handles nested expressions' do
      @field.max.min.avg.empty?.tokenize.to_s.should eql("TOKENIZE(IsEmpty(AVG(MIN(MAX(field)))))")
    end
  end
  
  context 'nested fields' do
    it 'handles nested field access' do
      @field.a.to_s.should eql('field.a')
    end
    
    it 'handles nested field access through #field' do
      @field.field(:a).to_s.should eql('field.a')
    end
    
    it 'handles nested field access throuh []' do
      @field[0].to_s.should eql('field.$0')
    end
  end
  
  context 'field renaming' do
    it 'supports renaming a field' do
      @field.as('x').to_s.should eql('field AS x')
    end
    
    it 'supports renaming a derived field' do
      @field.x.y.z.as('b').to_s.should eql('field.x.y.z AS b')
    end
    
    it 'supports renaming a calculated field' do
      @field.max.as('m').to_s.should eql('MAX(field) AS m')
    end
  end
  
  context 'infix and unary operators' do
    before do
      @field1 = Piglet::Field::Reference.new('field1')
      @field2 = Piglet::Field::Reference.new('field2')
    end
    
    [:==, :>, :<, :>=, :<=, :%, :+, :-, :*, :/].each do |op|
      it "supports #{op} on a field" do
        @field1.send(op, @field2).to_s.should eql("field1 #{op} field2")
      end

      if op != :+ # + is already covered in all other iterations, and it parenthesizes differently
        it "supports #{op} on an expression" do
          (@field1 + (@field1.send(op, @field2))).to_s.should eql("field1 + (field1 #{op} field2)")
        end
      end
    end
    
    it 'supports != through #ne on a field' do
      @field1.ne(@field2).to_s.should eql("field1 != field2")
    end
    
    it 'supports != through #ne on an expression' do
      (@field1 + (@field1.ne(@field2))).to_s.should eql("field1 + (field1 != field2)")
    end
    
    it 'supports "matches" on a field with a regex' do
      @field1.matches(/.*\.pig$/).to_s.should eql("field1 matches '.*\\.pig$'")
    end
    
    it 'supports "matches" on a field with a string' do
      @field1.matches('.*\.pig$').to_s.should eql("field1 matches '.*\\.pig$'")
    end
    
    it 'supports "matches" on an expression' do
      (@field1 + @field2).matches(/.*\.pig$/).to_s.should eql("(field1 + field2) matches '.*\\.pig$'")
    end
    
    it 'supports "is null" on a field' do
      @field1.null?.to_s.should eql("field1 is null")
    end
    
    it 'supports "is null" on an expression' do
      (@field1 + @field2).null?.to_s.should eql("(field1 + field2) is null")
    end
    
    it 'supports "is not null" on a field' do
      @field1.not_null?.to_s.should eql("field1 is not null")
    end
    
    it 'supports "is not null" on an expression' do
      (@field1 + @field2).not_null?.to_s.should eql("(field1 + field2) is not null")
    end
    
    it 'supports "NOT" on a field' do
      @field1.not.to_s.should eql("NOT field1")
    end
    
    it 'supports "NOT" on an expression' do
      (@field1 == @field2).not.to_s.should eql("NOT (field1 == field2)")
    end
    
    it 'supports unary - through #neg on a field' do
      @field1.neg.to_s.should eql("-field1")
    end

    it 'supports unary - through #neg on an expression' do
      (@field1 + @field2).neg.to_s.should eql("-(field1 + field2)")
    end
    
    it 'supports casts on a field' do
      @field1.cast(:chararray).to_s.should eql("(chararray) field1")
    end
    
    it 'supports casts on an expression' do
      (@field1 + @field2).cast(:chararray).to_s.should eql("(chararray) (field1 + field2)")
    end

    it 'supports AND though #and on fields' do
      @field1.and(@field2).to_s.should eql("field1 AND field2")
    end
    
    it 'supports AND through #and on expressions' do
      (@field1 + @field2).and(@field1 - @field2).to_s.should eql("(field1 + field2) AND (field1 - field2)")
    end

    it 'supports OR though #or on fields' do
      @field1.or(@field2).to_s.should eql("field1 OR field2")
    end
    
    it 'supports OR through #or on expressions' do
      (@field1 + @field2).or(@field1 - @field2).to_s.should eql("(field1 + field2) OR (field1 - field2)")
    end
  end
  
end