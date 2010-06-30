# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')


include Piglet::Field


describe Field do

  before do
    @field = mock('field')
    @field.extend Field
    @expressions = {}
    [:int, :long, :float, :double, :chararray, :bytearray, :bag, :tuple].each do |type|
      @expressions[type] = mock("#{type} expression")
      @expressions[type].extend Field
      @expressions[type].stub!(:type).and_return(type)
    end
  end
  
  it "should have an alias" do
    @field.field_alias.should_not be_nil
  end
  
  describe '#type' do
    [:==, :ne, :<, :>, :<=, :>=, :and, :or].each do |op|
      op_str = (op == :ne ? '!=' : op).to_s.upcase
      
      it "knows that a #{op_str} expression always is of type boolean" do
        (@field.send(op, @field)).type.should eql(:boolean)
      end
    end

    it 'knows that % yields an integer' do
      (@field % 5).type.should eql(:int)
    end
    
    it 'knows that a call to IsEmpty is of type boolean' do
      @field.empty?.type.should eql(:boolean)
    end
    
    it 'knows that the NOT operator yields a boolean' do
      @field.not.type.should eql(:boolean)
    end

    it 'knows that the "is null" operator yields a boolean' do
      @field.null?.type.should eql(:boolean)
    end

    it 'knows that the "is not null" operator yields a boolean' do
      @field.not_null?.type.should eql(:boolean)
    end
    
    [:int, :long, :float, :double, :chararray, :bytearray].each do |type|
      it "knows that a cast to #{type} is of type #{type}" do
        @field.cast(type).type.should eql(type)
      end
    end
    
    it 'knows that a "matches" expression is always of type boolean' do
      @field.matches(/hello world/).type.should eql(:boolean)
    end
    
    [:int, :long, :float, :double].each do |type|
      it "knows that negating a #{type} yields a #{type}" do
        @expressions[type].neg.type.should eql(type)
      end
    end

    [:+, :-, :*].each do |op|
      it "knows that int #{op} int yields an int" do
        (@expressions[:int].send(op, @expressions[:int])).type.should eql(:int)
      end

      it "knows that int #{op} long yields a long" do
        (@expressions[:int].send(op, @expressions[:long])).type.should eql(:long)
      end

      it "knows that int #{op} float yields a float" do
        (@expressions[:int].send(op, @expressions[:float])).type.should eql(:float)
      end

      it "knows that int #{op} double yields a double" do
        (@expressions[:int].send(op, @expressions[:double])).type.should eql(:double)
      end
    end
    
    combos = {
      [:int, :int] => :int,
      [:int, :long] => :long,
      [:int, :float] => :float,
      [:int, :double] => :double,
      [:long, :float] => :float,
      [:long, :double] => :double
    }
    
    combos.each do |operands, result|
      it "knows that #{operands[0]}/#{operands[1]} yields a #{result}" do
        (@expressions[operands[0]] / @expressions[operands[1]]).type.should eql(result)
      end

      it "knows that #{operands[1]}/#{operands[0]} yields a #{result}" do
        (@expressions[operands[1]] / @expressions[operands[0]]).type.should eql(result)
      end
    end
  end
  
end