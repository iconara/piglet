# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')


describe Piglet::Relation::Union do

  before do
    @interpreter = stub()
    @interpreter.stub(:next_relation_alias).and_return('relation1', 'relation2', 'relation3')
    @relation1 = PlainRelation.new(@interpreter)
    @relation2 = PlainRelation.new(@interpreter)
    @relation3 = PlainRelation.new(@interpreter)
  end

  describe '#to_s' do    
    it 'outputs the names of all the relations (given as separate arguments)' do
      pig_latin = @relation1.union(@relation2, @relation3).to_s
      pig_latin.should include('relation1')
      pig_latin.should include('relation2')
      pig_latin.should include('relation3')
    end

    it 'outputs the names of all the relations (given as an array)' do
      pig_latin = @relation1.union([@relation2, @relation3]).to_s
      pig_latin.should include('relation1')
      pig_latin.should include('relation2')
      pig_latin.should include('relation3')
    end
    
    it 'outputs a UNION statement with the right number of relations' do
      pig_latin = @relation1.union(@relation2, @relation3).to_s
      pig_latin.should match(/UNION \w+, \w+, \w+/)
    end
  end

end