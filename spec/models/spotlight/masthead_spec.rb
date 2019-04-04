# frozen_string_literal: true

describe Spotlight::Masthead, type: :model do
  let(:masthead) { stub_model(described_class) }

  describe '#iiif_url' do
    it 'inlcudes the appropriate size' do
      masthead.iiif_tilesource = 'http://example.com/iiif/abc123/info.json'
      expect(masthead.iiif_url).to match(%r{/full/1800,180/})
    end
  end

  describe '#display?' do
    let(:image) { OpenStruct.new }
    subject { masthead.display? }

    context 'when the masthead is set to not display' do
      it { is_expected.to be_falsey }
    end

    context 'when the cropped image is not present' do
      before { masthead.display = true }

      it { is_expected.to be_falsey }
    end

    context 'when the cropped image is present' do
      before do
        masthead.iiif_tilesource = 'http://test.host/images/1'
        masthead.iiif_region = '100,0,200,300'
      end

      context 'but the masthead is set to not display' do
        it { is_expected.to be_falsey }
      end

      context 'and the masthead is set to display' do
        before { masthead.display = true }

        it { is_expected.to be_truthy }
      end
    end
  end
end
