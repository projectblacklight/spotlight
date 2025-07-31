# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spotlight::Resources::IiifHarvester do
  subject(:harvester) { described_class.create(exhibit_id: exhibit.id, url:) }

  let(:exhibit) { FactoryBot.create(:exhibit) }

  let(:faraday_double) { instance_double(Faraday::Connection) }

  before do
    allow(Spotlight::Resources::IiifService).to receive(:http_client).and_return(faraday_double)
  end

  describe 'Validation' do
    context 'when given an invalid URL' do
      before do
        head_response = instance_double(Faraday::Response, status: 200, headers: { 'content-type' => 'text/html' }, success?: true)
        allow(faraday_double).to receive(:head).with('http://example.com').and_return(head_response)
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
        head_response = instance_double(Faraday::Response, status: 405, headers: { 'content-type' => 'text/html' }, success?: false)
        allow(faraday_double).to receive(:head).with('http://example.com').and_return(head_response)

        get_response = instance_double(Faraday::Response, status: 200, headers: { 'content-type' => 'application/ld+json' }, success?: true)
        allow(faraday_double).to receive(:get).with('http://example.com').and_return(get_response)
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
