# frozen_string_literal: true

describe Spotlight::FeaturedImageUploader do
  let(:mounter) { FactoryBot.create(:featured_image) }
  subject(:featured_image_uploader) { described_class.new(mounter, 'mounted_as') }

  describe '#extension_whitelist' do
    it 'is the configured array of approved extension to be uploaded' do
      expect(featured_image_uploader.extension_whitelist).to eq Spotlight::Engine.config.allowed_upload_extensions
    end
  end

  describe '#store_dir' do
    let(:store_dir) { featured_image_uploader.store_dir }

    it 'is prefixed with "uploads/spotlight"' do
      expect(store_dir).to start_with 'uploads/spotlight/'
    end

    it "includes the mounter's class name" do
      expect(store_dir).to match '/featured_image/'
    end

    it 'includes the mounted_as option' do
      expect(store_dir).to match '/mounted_as/'
    end

    it "ends with the mounter's id" do
      expect(store_dir).to end_with "/#{mounter.id}"
    end
  end
end
