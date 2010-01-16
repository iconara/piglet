# encoding: utf-8

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

    it 'accepts a Bag object as the type of a field' do
      tuple = Tuple.parse([[:a, Bag.new(Tuple.parse([:c, :d]))]])
      tuple.field_type(:a).should be_a(Bag)
      tuple.field_type(:a).field_names.should eql([:c, :d])
    end

    it 'can parse a Bag from a field typed as :bag' do
      tuple = Tuple.parse([[:a, :bag, [:c, :d]]])
      tuple.field_type(:a).should be_a(Bag)
      tuple.field_type(:a).field_names.should eql([:c, :d])
    end
    
    it 'can parse a description that lacks field names (and fall back to making the fields accessible by index)' do
      tuple = Tuple.parse([[nil, :chararray], [nil, :int]])
      tuple.field_type(1).should eql(:int)
    end
  end
  
  describe '#union' do
    it 'creates a new tuple with the fields from two tuples' do
      t1 = Tuple.parse([:a, :b, :c])
      t2 = Tuple.parse([:d, :e, :f])
      t3 = t1.union(t2)
      t3.field_names.should eql([:a, :b, :c, :d, :e, :f])
    end
    
    it 'creates a new tuple with the fields from three tuples' do
      t1 = Tuple.parse([:a, :b, :c])
      t2 = Tuple.parse([:d, :e, :f])
      t3 = Tuple.parse([:g, :h, :i])
      t4 = t1.union(t2, t3)
      t4.field_names.should eql([:a, :b, :c, :d, :e, :f, :g, :h, :i])
    end

    it 'creates a new tuple with the fields from three tuples (arguments as an array)' do
      t1 = Tuple.parse([:a, :b, :c])
      t2 = Tuple.parse([:d, :e, :f])
      t3 = Tuple.parse([:g, :h, :i])
      t4 = t1.union([t2, t3])
      t4.field_names.should eql([:a, :b, :c, :d, :e, :f, :g, :h, :i])
    end

    it 'retains all the fields even if some have the same name' do
      t1 = Tuple.parse([:a, :b, :c])
      t2 = Tuple.parse([:b, :c, :d])
      t3 = t1.union(t2)
      t3.field_names.should eql([:a, :b, :c, :b, :c, :d])
    end
  end

  describe '#to_s' do
    it 'returns the schema string for a simple untyped schema' do
      Tuple.parse([:a, :b]).to_s.should eql('(a:bytearray, b:bytearray)')
    end
    
    it 'returns the schema string for a simple typed schema' do
      Tuple.parse([[:a, :chararray], [:b, :int]]).to_s.should eql('(a:chararray, b:int)')
    end

    it 'returns the schema string for a nested schema' do
      description = [[:a, :tuple, [[:x, :int], [:y, :float]]], [:b, :bag, [[:w, :bytearray]]]]
      Tuple.parse(description).to_s.should eql('(a:tuple (x:int, y:float), b:bag {w:bytearray})')
    end
  end
  
end
