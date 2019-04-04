# frozen_string_literal: true

describe Spotlight::ExhibitThumbnail do
  subject(:exhibit_thumbnail) { described_class.new }

  it 'includes the appropriate size in the iiif_url' do
    exhibit_thumbnail.iiif_tilesource = 'http://example.com/iiif/abc123/info.json'
    expect(exhibit_thumbnail.iiif_url).to match(%r{/full/400,400/})
  end
end
