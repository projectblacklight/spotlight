require 'spec_helper'

describe Spotlight::SolrDocument::UploadedResource, type: :model do
  let(:valid_resource) do
    SolrDocument.new(id: '123',
                     full_image_url_ssm: ['http://example.com/png.png'],
                     spotlight_full_image_height_ssm: ['1400'],
                     spotlight_full_image_width_ssm: ['1000'],
                     spotlight_resource_type_ssim: ['spotlight/resources/uploads'])
  end

  describe 'SolrDocument.use_extension' do
    it 'does not include the uploaded resource extension when the spotlight resource type is not correct' do
      expect(SolrDocument.new(id: '123', spotlight_resource_type_ssim: ['not-correct'])).to_not be_a_kind_of(described_class)
    end
    it 'includes the uploaded resource extension when the correct fields are present with the correct data' do
      expect(valid_resource).to be_a_kind_of(described_class)
    end
  end
  describe 'to_openseadragon' do
    let(:subject) { valid_resource.to_openseadragon }
    it 'includes hashes for each full_image_url_ssm' do
      expect(subject).to be_an Array
      expect(subject.length).to eq 1
      expect(subject.first.keys.length).to eq 1
    end
    it 'the hashes key should be a LegacyImagePyramidTileSource object' do
      expect(subject.first.keys.first).to be_a(Spotlight::SolrDocument::UploadedResource::LegacyImagePyramidTileSource)
    end
    describe 'LegacyImagePyramidTileSource' do
      let(:subject) { valid_resource.to_openseadragon.first.keys.first.to_tilesource }
      it 'is a hash' do
        expect(subject).to be_a Hash
      end
      it 'is a legacy image pyramid type' do
        expect(subject[:type]).to eq 'legacy-image-pyramid'
      end
      describe 'levels' do
        it 'includes one level' do
          expect(subject[:levels].length).to eq 1
        end
        it 'includes the image url' do
          expect(subject[:levels].first[:url]).to eq 'http://example.com/png.png'
        end
        it 'includes the height and width from the document' do
          expect(subject[:levels].first[:height]).to eq '1400'
          expect(subject[:levels].first[:width]).to eq '1000'
        end
      end
    end
  end
end
