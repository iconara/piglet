# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')


include Piglet::Field


describe InfixExpression do

  before do
    @expressions = {}
    [:int, :long, :float, :double, :chararray, :bytearray, :bag, :tuple].each do |type|
      @expressions[type] = mock("#{type} expression")
      @expressions[type].extend Field
      @expressions[type].stub!(:type).and_return(type)
    end
  end
  
  describe '#type' do
    context 'specified' do
      it 'returns the type specified in the options' do
        expr = InfixExpression.new(@true_test, @expressions[:int], @expressions[:chararray], :type => :long)
        expr.type.should == :long
      end
    end
    
    context 'inferred' do
      it 'returns the type of the left expression if no other rules apply' do
        expr = InfixExpression.new('x', @expressions[:chararray], @expressions[:bytearray])
        expr.type.should == :chararray
      end
    
      it 'returns double if the lefthand type is a double' do
        expr = InfixExpression.new(@true_test, @expressions[:double], @expressions[:int])
        expr.type.should == :double
      end
    
      it 'returns double if the righthand type is a double' do
        expr = InfixExpression.new(@true_test, @expressions[:float], @expressions[:double])
        expr.type.should == :double
      end
    
      it 'returns double when the other operand is of type long' do
        expr = InfixExpression.new(@true_test, @expressions[:double], @expressions[:long])
        expr.type.should == :double
      end
    
      it 'returns float if one type is long and the other is a float' do
        expr = InfixExpression.new(@true_test, @expressions[:long], @expressions[:float])
        expr.type.should == :float
      end
    
      it 'returns long if the lefthand type is long, and the righthand is an int' do
        expr = InfixExpression.new(@true_test, @expressions[:long], @expressions[:int])
        expr.type.should == :long
      end
    
      it 'returns long if the righthand type is long, and the lefthand is an int' do
        expr = InfixExpression.new(@true_test, @expressions[:int], @expressions[:long])
        expr.type.should == :long
      end
        
      it 'returns float if one operand is of type int and the other is a float' do
        expr = InfixExpression.new(@true_test, @expressions[:int], @expressions[:float])
        expr.type.should == :float
      end
    end
  end
  
end