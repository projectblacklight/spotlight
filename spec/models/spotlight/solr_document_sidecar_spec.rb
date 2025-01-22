# frozen_string_literal: true

RSpec.describe Spotlight::SolrDocumentSidecar, type: :model do
  let(:exhibit) { FactoryBot.create(:exhibit) }

  before do
    allow(subject).to receive_messages(exhibit:)
    allow(subject).to receive_messages document: SolrDocument.new(id: 'doc_id')
  end

  describe '#to_solr' do
    before do
      subject.data = { 'a_tesim' => 1, 'b_tesim' => 2, 'c_tesim' => 3 }
    end

    its(:to_solr) { is_expected.to include id: 'doc_id' }
    its(:to_solr) { is_expected.to include "exhibit_#{exhibit.slug}_public_bsi": true }
    its(:to_solr) { is_expected.to include 'a_tesim', 'b_tesim', 'c_tesim' }

    context 'with an uploaded item' do
      before do
        subject.data = { 'configured_fields' => { 'some_configured_field' => 'some value' } }
        subject.resource = Spotlight::Resources::Upload.new
        allow(Spotlight::Resources::Upload).to receive(:fields).with(exhibit).and_return([uploaded_field_config])
      end

      let(:uploaded_field_config) do
        Spotlight::UploadFieldConfig.new(field_name: 'some_configured_field', solr_fields: ['the_solr_field'])
      end

      its(:to_solr) { is_expected.to include 'the_solr_field' => 'some value' }
    end

    context 'with blank fields' do
      before do
        subject.data = {
          'a_blank_field' => '',
          'a_blank_multivalued_field' => ['', ''],
          'a_multivalued_field_with_some_blanks' => ['', 'a']
        }
      end

      its(:to_solr) { is_expected.to include 'a_blank_field' => nil }
      its(:to_solr) { is_expected.to include 'a_blank_multivalued_field' => [] }
      its(:to_solr) { is_expected.to include 'a_multivalued_field_with_some_blanks' => ['a'] }
    end

    context 'with other data structures' do
      before do
        subject.data = {
          'a_hash_field' => { 'a' => 'b' }
        }
      end

      its(:to_solr) { is_expected.to include 'a_hash_field' => ['b'] }
    end
  end
end
