require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')


include Piglet::Field


describe BinaryConditional do

  before do
    @true_test = mock('test expression')
    @true_test.stub!(:to_s).and_return('true')
    @expressions = {}
    [:int, :long, :float, :double, :chararray, :bytearray, :bag, :tuple].each do |type|
      @expressions[type] = mock("#{type} expression")
      @expressions[type].extend Field
      @expressions[type].stub!(:type).and_return(type)
    end
  end
  
  describe '#type' do
    it 'returns the type of the true expression' do
      bincond = BinaryConditional.new(@true_test, @expressions[:int], @expressions[:float])
      bincond.type.should == :int
    end
    
    it 'returns int if the true expression is an Integer' do
      bincond = BinaryConditional.new(@true_test, 3, @expressions[:float])
      bincond.type.should == :int
    end
    
    it 'returns float if the true expression is a Float' do
      bincond = BinaryConditional.new(@true_test, 3.14, @expressions[:float])
      bincond.type.should == :float
    end
    
    it 'returns boolean if the true expression is true' do
      bincond = BinaryConditional.new(@true_test, true, @expressions[:float])
      bincond.type.should == :boolean
    end

    it 'returns boolean if the true expression is false' do
      bincond = BinaryConditional.new(@true_test, false, @expressions[:float])
      bincond.type.should == :boolean
    end
  end
  
end