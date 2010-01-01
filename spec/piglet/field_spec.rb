require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe Piglet::Field do

  before do
    @field = Piglet::Field.new('field')
  end
  
  describe '#to_s' do
    it 'returns a string with the field name (as a string)' do
      @field.to_s.should eql("field")
    end
    
    it 'returns a string with the field name (as a symbol)' do
      @field = Piglet::Field.new(:field)
      @field.to_s.should eql("field")
    end
  end

  %w(avg count diff max min size sum tokenize).each do |function_name|
    describe "##{function_name}" do
      it "wraps the field in a #{function_name.upcase} call" do
        @field.send(function_name).to_s.should eql("#{function_name.upcase}(field)")
      end
    end
  end
  
  describe "#is_empty?" do
    it "wraps the field in a IsEmpty call" do
      @field.is_empty?.to_s.should eql("IsEmpty(field)")
    end
  end
  
  context 'nested expressions' do
    it 'handles nested expressions' do
      @field.max.min.avg.is_empty?.tokenize.to_s.should eql("TOKENIZE(IsEmpty(AVG(MIN(MAX(field)))))")
    end
  end
  
  context 'field renaming' do
    it 'knows how to rename a field' do
      @field.as('x').to_s.should eql('field AS x')
    end
    
    it 'knows how to rename a derived field' do
      @field.x.y.z.as('b').to_s.should eql('field.x.y.z AS b')
    end
    
    it 'knows how to rename a calculated field' do
      @field.max.as('m').to_s.should eql('MAX(field) AS m')
    end
  end
  
  context 'infix operators' do
    before do
      @field1 = Piglet::Field.new('field1')
      @field2 = Piglet::Field.new('field2')
    end
    
    it 'handles ==' do
      (@field1 == @field2).to_s.should eql('field1 == field2')
    end
    
    # it 'handles !=' do
    #   (@field1 != @field2).to_s.should eql('field1 != field2')
    # end
    
    it 'handles >' do
      (@field1 > @field2).to_s.should eql('field1 > field2')
    end
    
    it 'handles <' do
      (@field1 < @field2).to_s.should eql('field1 < field2')
    end
    
    it 'handles >=' do
      (@field1 >= @field2).to_s.should eql('field1 >= field2')
    end
    
    it 'handles <=' do
      (@field1 <= @field2).to_s.should eql('field1 <= field2')
    end
    
    it 'handles %' do
      (@field1 % @field2).to_s.should eql('field1 % field2')
    end
  end
  
end