require 'spec_helper'

describe Spotlight::Resource do
  before do
    Spotlight::Resource.any_instance.stub(:reindex)
  end

  its(:to_solr) { should be_a_kind_of Hash }

  it "should reindex after save" do
    subject.should_receive(:reindex)
    subject.should_receive(:update_index_time!)
    subject.data = {}
    subject.save
  end

  it "should store arbitrary data" do
    subject.data[:a] = 1
    subject.data[:b] = 2

    expect(subject.data[:a]).to eq 1
    expect(subject.data[:b]).to eq 2
  end

  describe "#update_index_time!" do
    it "should update the index_time column" do
      subject.should_receive(:update_columns).with(hash_including(:indexed_at))
      subject.update_index_time!
    end
  end
end