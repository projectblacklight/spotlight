# frozen_string_literal: true

describe Spotlight::AttachmentUploader do
  let(:mounter) { Spotlight::Attachment.new(id: '5') }
  subject(:attachment_uploader) { described_class.new(mounter, 'mounted_as') }

  describe '#store_dir' do
    let(:store_dir) { attachment_uploader.store_dir }

    it 'is prefixed with "uploads/spotlight"' do
      expect(store_dir).to start_with 'uploads/spotlight/'
    end

    it "includes the mounter's class name" do
      expect(store_dir).to match '/attachment/'
    end

    it 'includes the mounted_as option' do
      expect(store_dir).to match '/mounted_as/'
    end

    it "ends with the mounter's id" do
      expect(store_dir).to end_with "/#{mounter.id}"
    end
  end
end
