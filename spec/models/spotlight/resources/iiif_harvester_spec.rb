require 'spec_helper'

describe Spotlight::Resources::IiifHarvester do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:harvester) { described_class.create(exhibit_id: exhibit.id, url: url) }

  describe 'Validation' do
    subject { harvester }
    context 'when given an invalid URL' do
      before do
        stub_request(:head, 'http://example.com').to_return(status: 200, headers: { 'Content-Type' => 'text/html' })
      end
      let(:url) { 'http://example.com' }

      it 'errors when the URL is not a IIIF URL' do
        expect(subject).to_not be_valid
        expect(subject.errors).to be_present
        expect(subject.errors[:url]).to eq ['Invalid IIIF URL']
      end
    end
    context 'when not responding to a HEAD request' do
      before do
        stub_request(:head, 'http://example.com').to_return(status: 405, headers: { 'Content-Type' => 'text/html' })
        stub_request(:get, 'http://example.com').to_return(status: 200, headers: { 'Content-Type' => ' application/ld+json' })
      end
      let(:url) { 'http://example.com' }

      it 'no errors when the URL responds to the GET request' do
        expect(subject).to be_valid
        expect(subject.errors).not_to be_present
      end
    end
  end

  describe '#documents_to_index' do
    let(:url) { 'uri://for-top-level-collection' }
    before { stub_default_collection }
    subject { harvester.document_builder }

    it 'returns an Enumerator of all the solr documents' do
      expect(subject.documents_to_index).to be_a(Enumerator)
      expect(subject.documents_to_index.count).to eq 8
    end
  end
end
