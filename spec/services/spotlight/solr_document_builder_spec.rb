describe Spotlight::SolrDocumentBuilder do
  let(:exhibit) { FactoryBot.create(:exhibit) }
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
  end

  describe '#documents_to_index' do
    context 'when the document belongs to more than one exhibit' do
      let(:doc) { SolrDocument.new(id: 'abc123') }
      let(:resource) { FactoryBot.create(:resource) }
      let(:resource_alt) { FactoryBot.create(:resource) }
      subject { resource.document_builder }

      before do
        allow(Spotlight::Engine.config).to receive(:filter_resources_by_exhibit).and_return(true)
        allow(resource.document_builder).to receive(:to_solr).and_return(id: 'abc123')
        allow(resource_alt.document_builder).to receive(:to_solr).and_return(id: 'abc123')
        resource_alt.document_builder.documents_to_index.first
      end

      it 'has filter data for both exhibits' do
        result = resource.document_builder.documents_to_index.first
        expect(result).to include "spotlight_exhibit_slug_#{resource.exhibit.slug}_bsi"
        expect(result).to include "spotlight_exhibit_slug_#{resource_alt.exhibit.slug}_bsi"
      end

      it 'has a field with both exhibit slugs listed' do
        result = resource.document_builder.documents_to_index.first
        expect(result).to include 'spotlight_exhibit_slugs_ssim' => match_array([resource.exhibit.slug, resource_alt.exhibit.slug])
      end

      it 'creates a sidecar resource for the document' do
        resource.document_builder.documents_to_index.first

        expect(Spotlight::SolrDocumentSidecar.where(document_id: 'abc123', document_type: 'SolrDocument').size).to eq 2
        sidecar = resource.solr_document_sidecars.find_by(document_id: 'abc123', document_type: 'SolrDocument')
        expect(sidecar.exhibit).to eq resource.exhibit
        expect(sidecar.resource).to eq resource
      end
    end
  end
end
