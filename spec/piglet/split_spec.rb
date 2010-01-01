require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe Piglet::Split do

  before do
    @relation = mock('source')
    @expr1 = mock('expr1')
    @expr2 = mock('expr2')
    @relation.stub!(:alias).and_return('rel')
    @expr1.stub!(:to_s).and_return('y')
    @expr2.stub!(:to_s).and_return('w')
    @split = Piglet::Split.new(@relation, [@expr1, @expr2])
  end

  describe '#to_s' do
    it 'outputs all x IF y expressions' do
      @split.to_s.should match(/SPLIT rel INTO \w+ IF y, \w+ IF w/)
    end
    
    it 'contains the names of all the shard relations' do
      @shards = @split.shards
      @split.to_s.should eql("SPLIT rel INTO #{@shards[0].alias} IF w, #{@shards[1].alias} IF y")
    end
  end
  
  describe '#shards' do
    it 'returns the same number of shards as there are expressions' do
      @split.shards.size.should == 2
    end
  end

end