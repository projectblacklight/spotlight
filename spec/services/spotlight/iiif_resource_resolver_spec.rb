# frozen_string_literal: true

describe Spotlight::IiifResourceResolver do
  let(:fixture_json) do
    File.open(
      File.expand_path(File.join('..', 'spec', 'fixtures', 'gk446cj2442-manifest.json'), Rails.root)
    ).read
  end
  let(:iiif_manifest_url) { 'https://purl.stanford.edu/gk446cj2442/manifest.json' }
  let(:resource) do
    FactoryBot.create(
      :featured_image,
      iiif_manifest_url: iiif_manifest_url,
      iiif_image_id: 'https://purl.stanford.edu/gk446cj2442/iiif/annotation/gk446cj2442_1',
      iiif_canvas_id: 'https://purl.stanford.edu/gk446cj2442/iiif/canvas/gk446cj2442_1',
      iiif_tilesource: 'https://stacks.stanford.edu/image/iiif/gk446cj2442%2Fgk446cj2442_05_0001/info.json'
    )
  end

  subject(:resolver) { described_class.new(resource) }

  before do
    expect(resolver).to receive(:response).and_return(fixture_json)
  end

  context 'success' do
    context 'when the tilesource has changed' do
      before do
        resource.iiif_tilesource = 'a-tilesource-that-no-longer-exists'
        resource.save
      end

      it 'the resource is updated and saved' do
        expect(resource).to receive(:save).and_call_original
        resolver.resolve!
        expect(resource.reload.iiif_tilesource).to eq 'https://stacks.stanford.edu/image/iiif/gk446cj2442%2Fgk446cj2442_05_0001/info.json'
      end
    end

    context 'when the tilesource has not changed' do
      it 'the resource is not saved' do
        expect(resource).not_to receive(:save)
        resolver.resolve!
      end

      it 'a statment indicating nothing was changed is loged' do
        expect(Rails.logger).to receive(:info).with(
          "Spotlight::IiifResourceResolver resolved #{iiif_manifest_url}, but nothing changed."
        )
        resolver.resolve!
      end
    end
  end

  context 'failure' do
    before do
      expect(resource).not_to receive(:save) # No spec should trigger a save under failure
    end

    context 'when the stored canvas ID is not present' do
      it 'raises a ManifestError' do
        resource.iiif_canvas_id = 'not-a-real-canvas-id'

        expect { resolver.resolve! }.to raise_error(
          Spotlight::IiifResourceResolver::ManifestError,
          "No canvas with @id not-a-real-canvas-id found in #{iiif_manifest_url}"
        )
      end
    end

    context 'when the stored canvas ID is not present' do
      it 'raises a ManifestError' do
        resource.iiif_image_id = 'not-a-real-image-id'

        expect { resolver.resolve! }.to raise_error(
          Spotlight::IiifResourceResolver::ManifestError,
          "No image with @id not-a-real-image-id found in #{iiif_manifest_url}"
        )
      end
    end

    context 'when the JSON is unparsable' do
      let(:fixture_json) { 'Some sort of html error!' }
      it 'logs that the JSON was unparsable and falls through to an no-canvas error' do
        klass = described_class.name
        expect(Rails.logger).to receive(:warn).with(
          a_string_matching(/#{klass} failed to parse #{iiif_manifest_url} with: \d{3}: unexpected token at '#{fixture_json}'/)
        )
        expect { resolver.resolve! }.to raise_error(Spotlight::IiifResourceResolver::ManifestError)
      end
    end
  end
end
