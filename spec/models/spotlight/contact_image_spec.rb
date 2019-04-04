# frozen_string_literal: true

describe Spotlight::ContactImage do
  subject(:contact_image) do
    described_class.new(iiif_tilesource: 'http://example.com/iiif/abc123/info.json')
  end

  it 'has the appropriate contact image size' do
    expect(contact_image.iiif_url).to match(%r{/full/70,70/})
  end
end
