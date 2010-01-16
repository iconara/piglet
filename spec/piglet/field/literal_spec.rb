# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')


include Piglet::Field


describe Literal do

  describe '#type' do
    it 'knows that the type of a string is chararray' do
      Literal.new("hello world").type.should eql(:chararray)
    end

    it 'knows that the type of an integer is int' do
      Literal.new(3).type.should eql(:int)
    end

    it 'knows that the type of a float is double' do
      Literal.new(3.14).type.should eql(:double)
    end
    
    it 'uses the specified type instead of the inferred' do
      Literal.new(3.14, :type => :float).type.should eql(:float)
    end
  end

end