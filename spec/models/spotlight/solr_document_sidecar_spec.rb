describe Spotlight::SolrDocumentSidecar, type: :model do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  before do
    allow(subject).to receive_messages exhibit: exhibit
    allow(subject).to receive_messages document: SolrDocument.new(id: 'doc_id')
  end

  describe '#to_solr' do
    before do
      subject.data = { 'a_tesim' => 1, 'b_tesim' => 2, 'c_tesim' => 3 }
    end

    its(:to_solr) { should include id: 'doc_id' }
    its(:to_solr) { should include "exhibit_#{exhibit.slug}_public_bsi".to_sym => true }
    its(:to_solr) { should include 'a_tesim', 'b_tesim', 'c_tesim' }

    context 'with an uploaded item' do
      before do
        subject.data = { 'configured_fields' => { 'some_configured_field' => 'some value' } }
        allow(Spotlight::Resources::Upload).to receive(:fields).with(exhibit).and_return([uploaded_field_config])
      end

      let(:uploaded_field_config) do
        Spotlight::UploadFieldConfig.new(field_name: 'some_configured_field', solr_fields: ['the_solr_field'])
      end

      its(:to_solr) { should include 'the_solr_field' => 'some value' }
    end
  end
end
