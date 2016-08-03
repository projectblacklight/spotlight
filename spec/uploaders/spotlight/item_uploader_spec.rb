require 'carrierwave/test/matchers'

describe Spotlight::ItemUploader do
  include CarrierWave::Test::Matchers
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:resource) { stub_model(Spotlight::Resources::Upload, exhibit: exhibit) }

  describe 'default configuration' do
    subject do
      described_class.new(resource, :resource)
    end

    before do
      subject.store!(File.open(File.expand_path(File.join('..', 'spec', 'fixtures', '800x600.png'), Rails.root)))
    end

    after do
      subject.remove!
    end

    it 'stores the file in the filesystem' do
      expect(File).to exist(".internal_test_app/public/uploads/spotlight/resources/upload/resource/#{subject.model.id}/800x600.png")
    end
  end
end
