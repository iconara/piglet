require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe Piglet::Relation do
  
  before do
    @relation = Object.new
    @relation.extend Piglet::Relation
  end
  
  it 'has a name' do
    @relation.name.should_not be_nil
  end
  
  it 'has a unique name' do
    names = { }
    1000.times do
      @relation = Object.new
      @relation.extend Piglet::Relation
      names.should_not have_key(@relation.name)
      names[@relation.name] = @relation
    end
  end
  
end
