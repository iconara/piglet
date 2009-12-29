require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe Piglet::Relation do
  
  before do
    @relation = Object.new
    @relation.extend Piglet::Relation
  end
  
  it 'has a alias' do
    @relation.alias.should_not be_nil
  end
  
  it 'has a unique alias' do
    aliases = { }
    1000.times do
      @relation = Object.new
      @relation.extend Piglet::Relation
      aliases.should_not have_key(@relation.alias)
      aliases[@relation.alias] = @relation
    end
  end
  
  describe '#group' do
    it 'returns a new relation with the target relation as source' do
      @relation.group(:a).sources.should include(@relation)
    end
  end
  
  describe '#distinct' do
    it 'returns a new relation with the target relation as source' do
      @relation.distinct.sources.should include(@relation)
    end
  end
  
  describe '#cross' do
    it 'returns a new relation with the target relation as one of the sources' do
      other = Object.new
      other.extend Piglet::Relation
      @relation.cross(other).sources.should include(@relation)
    end
  end
  
  describe '#union' do
    it 'returns a new relation with the target relation as one of the sources' do
      other = Object.new
      other.extend Piglet::Relation
      @relation.union(other).sources.should include(@relation)
    end
  end
  
  describe '#sample' do
    it 'returns a new relation with the target relation as source' do
      @relation.sample(10).sources.should include(@relation)
    end
  end

  describe '#limit' do
    it 'returns a new relation with the target relation as source' do
      @relation.limit(42).sources.should include(@relation)
    end
  end
  
end
