# frozen_string_literal: true

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
    subject(:osd) { valid_resource.to_openseadragon }
    let(:uploaded_resource) { instance_double(Spotlight::Resources::Upload, upload: upload) }
    let(:upload) { instance_double(Spotlight::FeaturedImage, iiif_tilesource: '/whatever/info.json') }

    before do
      allow(valid_resource).to receive(:uploaded_resource).and_return(uploaded_resource)
    end

    it 'includes hashes for each full_image_url_ssm' do
      expect(osd).to be_an Array
      expect(osd.length).to eq 1
      expect(osd.first).to end_with '/whatever/info.json'
    end
  end
end
