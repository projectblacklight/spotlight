require 'spec_helper'

describe Spotlight::Resource, type: :model do
  before do
    allow_any_instance_of(described_class).to receive(:update_index)
  end
  let(:exhibit) { FactoryGirl.create(:exhibit) }

  describe '#to_solr' do
    before do
      allow(subject).to receive(:exhibit).and_return(exhibit)
      allow(subject).to receive_messages(type: 'Spotlight::Resource::Something', id: 15, persisted?: true)
    end
    it 'includes a reference to the resource' do
      expect(subject.to_solr).to include spotlight_resource_id_ssim: subject.to_global_id.to_s
    end

    it 'includes exhibit-specific data' do
      allow(exhibit).to receive(:solr_data).and_return(exhibit_data: true)
      expect(subject.to_solr).to include exhibit_data: true
    end
  end

  describe '#reindex' do
    context 'with a provider that generates ids' do
      subject do
        Class.new(described_class) do
          def to_solr
            super.merge(id: 123)
          end
        end.new(exhibit: exhibit)
      end

      before do
        SolrDocument.new(id: 123).sidecars.create!(exhibit: exhibit, data: { document_data: true })
        allow(subject).to receive_messages(to_global_id: '', update_index_time!: nil)
      end

      it 'includes exhibit document-specific data' do
        expect(subject.send(:blacklight_solr)).to receive(:update) do |options|
          data = JSON.parse(options[:data], symbolize_names: true)

          expect(data.length).to eq 1
          doc = data.first

          expect(doc).to include document_data: true
        end

        subject.reindex
      end
    end
  end

  describe '#becomes_provider' do
    it 'converts the resource to a provider-specific resource' do
      SomeClass = Class.new(described_class)
      allow(Spotlight::ResourceProvider).to receive_messages(for_resource: SomeClass)
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
