require 'spec_helper'

describe Spotlight::Resource, type: :model do
  before do
    allow_any_instance_of(described_class).to receive(:update_index)
  end
  let(:exhibit) { double(solr_data: {}) }

  describe '.class_for_resource' do
    let(:thing) { double }
    let(:type_a) { double('TypeA', weight: 10) }
    let(:type_b) { double('TypeB', weight: 5) }
    let(:providers) { [type_a, type_b] }
    subject { described_class.class_for_resource(thing) }

    before do
      allow(described_class).to receive_messages(providers: providers)
    end

    it 'returns a class that can provide indexing for the resource' do
      expect(type_a).to receive(:can_provide?).with(thing).and_return(true)
      expect(type_b).to receive(:can_provide?).with(thing).and_return(false)
      expect(subject).to eq type_a
    end

    it 'returns the lowest weighted class that can provide indexing for the resource' do
      expect(type_a).to receive(:can_provide?).with(thing).and_return(true)
      expect(type_b).to receive(:can_provide?).with(thing).and_return(true)
      expect(subject).to eq type_b
    end
  end

  describe '#to_solr' do
    before do
      allow(subject).to receive(:exhibit).and_return(exhibit)
      allow(subject).to receive_messages(type: 'Spotlight::Resource::Something', id: 15)
    end
    it 'includes a reference to the resource' do
      expect(subject.to_solr).to include spotlight_resource_id_ssim: subject.to_global_id.to_s
    end

    it 'includes exhibit-specific data' do
      allow(exhibit).to receive(:solr_data).and_return(exhibit_data: true)
      expect(subject.to_solr).to include exhibit_data: true
    end
  end

  describe '#becomes_provider' do
    it 'converts the resource to a provider-specific resource' do
      SomeClass = Class.new(described_class)
      allow(described_class).to receive_messages(class_for_resource: SomeClass)
      expect(subject.becomes_provider).to be_a_kind_of(SomeClass)
      expect(subject.becomes_provider.type).to eq 'SomeClass'
    end
  end

  it 'reindexs after save' do
    expect(subject).to receive(:reindex)
    subject.data_will_change!
    subject.save!
  end

  it 'stores arbitrary data' do
    subject.data[:a] = 1
    subject.data[:b] = 2

    expect(subject.data[:a]).to eq 1
    expect(subject.data[:b]).to eq 2
  end

  describe '#update_index_time!' do
    it 'updates the index_time column' do
      expect(subject).to receive(:update_columns).with(hash_including(:indexed_at))
      subject.update_index_time!
    end
  end

  describe '#save_and_commit' do
    it 'saves the object and commit to solr' do
      expect(subject).to receive(:save)
      expect(subject.send(:blacklight_solr)).to receive(:commit)
      subject.save_and_commit
    end
  end
end
