# frozen_string_literal: true

require 'spec_helper'

describe Spotlight::Resources::IiifHarvester do
  subject(:harvester) { described_class.create(exhibit_id: exhibit.id, url:) }

  let(:exhibit) { FactoryBot.create(:exhibit) }

  describe 'Validation' do
    context 'when given an invalid URL' do
      before do
        stub_request(:head, 'http://example.com').to_return(status: 200, headers: { 'Content-Type' => 'text/html' })
      end

      let(:url) { 'http://example.com' }

      it 'errors when the URL is not a IIIF URL' do
        expect(subject).not_to be_valid
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

  describe '#reindex' do
    let(:url) { 'uri://for-top-level-collection' }

    before do
      stub_default_collection
      allow(Spotlight::Engine.config).to receive(:writable_index).and_return(false)
    end

    it 'indexes all the solr documents' do
      expect(subject.reindex).to eq 8
    end
  end
end
