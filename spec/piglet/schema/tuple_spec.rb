require File.dirname(__FILE__) + '/../../spec_helper'


include Piglet::Schema


describe Tuple do
  
  describe '.parse' do
    it 'can parse a non-typed, single field description' do
      tuple = Tuple.parse([:a])
      tuple.field_names.should eql([:a])
    end

    it 'can parse a non-typed, multiple field description' do
      tuple = Tuple.parse([:a, :b, :c])
      tuple.field_names.should eql([:a, :b, :c])
    end

    it 'can parse a typed, single field description' do
      tuple = Tuple.parse([[:a, :chararray]])
      tuple.field_names.should eql([:a])
      tuple.field_type(:a).should eql(:chararray)
    end

    it 'can parse a typed, multiple field description' do
      tuple = Tuple.parse([[:a, :chararray], [:b, :double]])
      tuple.field_names.should eql([:a, :b])
      tuple.field_type(:a).should eql(:chararray)
      tuple.field_type(:b).should eql(:double)
    end

    it 'can parse a mixed typed and non-typed field description' do
      tuple = Tuple.parse([:a, [:b, :double]])
      tuple.field_names.should eql([:a, :b])
      tuple.field_type(:b).should eql(:double)
    end

    it 'defaults to :bytearray for untyped fields' do
      tuple = Tuple.parse([:a])
      tuple.field_type(:a).should eql(:bytearray)
    end

    it 'accepts a Tuple object as the type of a field' do
      tuple = Tuple.parse([[:a, Tuple.parse([:c, :d])]])
      tuple.field_type(:a).should be_a(Tuple)
      tuple.field_type(:a).field_names.should eql([:c, :d])
    end

    it 'can parse a Tuple from a field typed as :tuple' do
      tuple = Tuple.parse([[:a, :tuple, [:c, :d]]])
      tuple.field_type(:a).should be_a(Tuple)
      tuple.field_type(:a).field_names.should eql([:c, :d])
    end
  end
  
end
