# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spotlight::ManifestService do
  let(:document) { SolrDocument.new }
  let(:manifest_service) { described_class.new(document: document) }
  let(:iiif_manifest_url) { '/manifest' }

  describe '#url' do
    it 'returns the correct url for the given document' do
      allow(document).to receive(:response).and_return(
        response: { docs: [iiif_manifest_url_ssi: iiif_manifest_url] }
      )
      expect(manifest_service.url).to eq(iiif_manifest_url)
    end
  end
end
