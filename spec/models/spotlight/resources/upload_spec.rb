require 'spec_helper'

describe Spotlight::Resources::Upload, :type => :model do
  let!(:exhibit) { FactoryGirl.create :exhibit }
  let!(:custom_field) { FactoryGirl.create :custom_field, exhibit: exhibit }
  before do
    subject.exhibit = exhibit
  end
  describe '#to_solr' do
    before do
      subject.id = "1"
      subject.data = {
        configured_title_field: "Title Data",
        spotlight_upload_description_tesim: "Description Data",
        spotlight_upload_attribution_tesim: "Attribution Data",
        spotlight_upload_date_tesim: "Date Data",
        custom_field.field => "Custom Field Data"
      }
      allow(subject).to receive(:url).and_return(stub_model(Spotlight::ItemUploader))
      allow(subject.url.file).to receive(:file).and_return(File.expand_path(File.join('..', 'fixtures', '800x600.png'), Rails.root))
      allow(subject.exhibit).to receive(:blacklight_config).and_return(
        Blacklight::Configuration.new do |config|
          config.index.title_field = :configured_title_field
        end
      )
    end
    it 'should have the exhibit id and the upload id as the solr id' do
      expect(subject.to_solr[:id]).to eq "#{subject.exhibit.id}-#{subject.id}"
    end
    it 'should have a title field using the exhibit specific blacklight_config' do
      expect(subject.to_solr[:configured_title_field]).to eq 'Title Data'
    end
    it 'should have the other additional configured fields' do
      expect(subject.to_solr[Spotlight::Engine.config.uploaded_description_field]).to eq "Description Data"
      expect(subject.to_solr[Spotlight::Engine.config.uploaded_attribution_field]).to eq "Attribution Data"
      expect(subject.to_solr[Spotlight::Engine.config.uploaded_date_field]).to eq "Date Data"
    end

    context "multiple solr field mappings" do

      let :configured_fields do
        [
          OpenStruct.new(field_name: 'some_field', solr_field: ['a', 'b'])
        ]
      end

      before do
        allow(subject).to receive(:configured_fields).and_return configured_fields

        subject.data = { 'some_field' => 'value'}
      end

      it "should map a single uploaded field to multiple solr fields" do
        expect(subject.to_solr['a']).to eq 'value'
        expect(subject.to_solr['b']).to eq 'value'
      end
    end

    it 'should have a spotlight_resource_type field' do
      expect(subject.to_solr[:spotlight_resource_type_ssim]).to eq 'spotlight/resources/uploads'
    end
    it 'should have the various image fields' do
      expect(subject.to_solr).to have_key Spotlight::Engine.config.full_image_field
      expect(subject.to_solr).to have_key Spotlight::Engine.config.thumbnail_field
      expect(subject.to_solr).to have_key Spotlight::Engine.config.square_image_field
    end
    it 'should have the full image dimensions fields' do
      expect(subject.to_solr[:spotlight_full_image_height_ssm]).to eq 600
      expect(subject.to_solr[:spotlight_full_image_width_ssm]).to eq 800
    end
    it 'should have fields representing exhibit specific custom fields' do
      expect(subject.to_solr[custom_field.field]).to eq "Custom Field Data"
    end
  end
end
