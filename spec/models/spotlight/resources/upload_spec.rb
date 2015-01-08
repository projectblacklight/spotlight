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
      allow(subject).to receive(:url).and_return(stub_model(Spotlight::Resources::Upload))
      allow(subject.url).to receive(:url).and_return('url-data')
      allow(subject.exhibit).to receive(:blacklight_config).and_return(
        Blacklight::Configuration.new do |config|
          config.index.title_field = :configured_title_field
          config.index.thumbnail_field = :configured_thumbnail_field
        end
      )
    end
    it 'should have the exhibit id and the upload id as the solr id' do
      expect(subject.to_solr[:id]).to eq "#{subject.exhibit.id}-#{subject.id}"
    end
    it 'should have a title field using the exhibit specific blacklight_config' do
      expect(subject.to_solr[:configured_title_field]).to eq 'Title Data'
    end
    it 'should have a thumbnail field using the exhibit specific blacklight_config' do
      expect(subject.to_solr[:configured_thumbnail_field]).to eq 'url-data'
    end
  end
end
