describe Spotlight::SolrDocumentBuilder do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:doc_builder) { described_class.new(resource) }
  let(:resource) { Spotlight::Resource.new }

  describe '#to_solr' do
    subject { doc_builder.send(:to_solr) }

    before do
      allow(resource).to receive(:exhibit).and_return(exhibit)
      allow(resource).to receive_messages(type: 'Spotlight::Resource::Something', id: 15, persisted?: true)
    end
    it 'includes a reference to the resource' do
      expect(subject).to include spotlight_resource_id_ssim: resource.to_global_id.to_s
    end

    it 'includes exhibit-specific data' do
      allow(exhibit).to receive(:solr_data).and_return(exhibit_data: true)
      expect(subject).to include exhibit_data: true
    end
  end
end
