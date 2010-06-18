# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')


describe Piglet::Relation::Split do

  before do
    @relation = mock('source')
    @expr1 = mock('expr1')
    @expr2 = mock('expr2')
    @relation.stub!(:alias).and_return('rel')
    @expr1.stub!(:to_s).and_return('expr1')
    @expr2.stub!(:to_s).and_return('expr2')
    @interpreter = mock('Interpreter')
    @interpreter.stub(:next_relation_alias).and_return(3)
    @split = Piglet::Relation::Split.new(@relation, @interpreter, [@expr1, @expr2])
  end

  describe '#to_s' do
    it 'outputs all x IF y expressions' do
      @split.to_s.should match(/SPLIT rel INTO \w+ IF expr[12], \w+ IF expr[12]/)
    end
    
    it 'contains the names of all the shard relations' do
      @shards = @split.shards
      @split.to_s.should include("#{@shards[0].alias} IF expr1")
      @split.to_s.should include("#{@shards[1].alias} IF expr2")
    end
  end
  
  describe '#shards' do
    it 'returns the same number of shards as there are expressions' do
      @split.shards.size.should == 2
    end
  end

end