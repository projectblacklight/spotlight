require 'spec_helper'

describe Spotlight::FeaturedImage do
  context 'with an uploaded resource' do
    subject { described_class.new }
    let(:document) { double(uploaded_resource?: true) }

    it 'replaces the remote_image_url fragment with the local path to the file' do
      allow(document).to receive_message_chain(:uploaded_resource, :url, file: File.open(File.join(FIXTURES_PATH, 'avatar.png')))
      allow(subject).to receive(:document).and_return(document)

      subject.remote_image_url = '/some/path'
      expect(subject.remote_image_url).to be_nil

      subject.validate

      expect(subject.image.filename).to eq 'avatar.png'
    end
  end
end
