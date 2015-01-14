require 'spec_helper'

describe Spotlight::Resources::Upload, :type => :model do
  let(:exhibit) { FactoryGirl.create :exhibit }
  before do
    subject.exhibit = exhibit
  end
  describe '#to_solr' do
    before do
      subject.id = "1"
      subject.data = {title: "Title Data"}
      allow(subject).to receive(:url).and_return(stub_model(Spotlight::ItemUploader))
      allow(subject.url.file).to receive(:file).and_return(File.expand_path(File.join('..', 'fixtures', '800x600.png'), Rails.root))
      allow(subject.exhibit).to receive(:blacklight_config).and_return(
        Blacklight::Configuration.new do |config|
          config.index.title_field = :configured_title_field
          config.index.full_image_field = :configured_full_image_field
          config.index.thumbnail_field = :configured_thumbnail_field
          config.index.square_image_field = :configured_square_field
        end
      )
    end
    it 'should have the exhibit id and the upload id as the solr id' do
      expect(subject.to_solr[:id]).to eq "#{subject.exhibit.id}-#{subject.id}"
    end
    it 'should have a title field using the exhibit specific blacklight_config' do
      expect(subject.to_solr[:configured_title_field]).to eq 'Title Data'
    end
    it 'should have a spotlight_resource_type field' do
      expect(subject.to_solr[:spotlight_resource_type_ssm]).to eq 'spotlight/resources/uploads'
    end
    it 'should have the various image fields' do
      expect(subject.to_solr).to have_key :configured_full_image_field
      expect(subject.to_solr).to have_key :configured_thumbnail_field
      expect(subject.to_solr).to have_key :configured_square_field
    end
    it 'should have the full image dimensions fields' do
      expect(subject.to_solr[:spotlight_full_image_height_ssm]).to eq 600
      expect(subject.to_solr[:spotlight_full_image_width_ssm]).to eq 800
    end
  end
end
