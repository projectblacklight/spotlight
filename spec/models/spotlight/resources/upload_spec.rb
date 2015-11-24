require 'spec_helper'

describe Spotlight::Resources::Upload, type: :model do
  let!(:exhibit) { FactoryGirl.create :exhibit }
  let!(:custom_field) { FactoryGirl.create :custom_field, exhibit: exhibit }
  before do
    subject.exhibit = exhibit
  end

  let(:configured_fields) { [title_field] + described_class.fields(exhibit) }
  let(:title_field) { OpenStruct.new(field_name: 'configured_title_field') }
  let(:upload_data) do
    {
      title_field.field_name => 'Title Data',
      'spotlight_upload_description_tesim' => 'Description Data',
      'spotlight_upload_attribution_tesim' => 'Attribution Data',
      'spotlight_upload_date_tesim' => 'Date Data',
      custom_field.field => 'Custom Field Data'
    }
  end

  before do
    allow(subject).to receive(:configured_fields).and_return configured_fields
    allow(described_class).to receive(:fields).and_return configured_fields

    allow(subject.send(:blacklight_solr)).to receive(:update)
    allow(Spotlight::Engine.config).to receive(:upload_title_field).and_return(title_field)
    subject.data = upload_data
    subject.url = File.open(File.join(FIXTURES_PATH, '800x600.png'))
    subject.save
  end

  context 'with a custom upload title field' do
    let(:title_field) { OpenStruct.new(field_name: 'configured_title_field', solr_field: :some_other_field) }

    describe '#to_solr' do
      it 'stores the title field in the provided solr field' do
        expect(subject.to_solr[:some_other_field]).to eq 'Title Data'
      end
    end
  end

  context 'multiple solr field mappings' do
    let :configured_fields do
      [
        OpenStruct.new(field_name: 'some_field', solr_field: %w(a b))
      ]
    end

    let :upload_data do
      { 'some_field' => 'value' }
    end

    describe '#to_solr' do
      it 'maps a single uploaded field to multiple solr fields' do
        expect(subject.to_solr['a']).to eq 'value'
        expect(subject.to_solr['b']).to eq 'value'
      end
    end
  end

  describe '#to_solr' do
    it 'has the exhibit id and the upload id as the solr id' do
      expect(subject.to_solr[:id]).to eq "#{subject.exhibit.id}-#{subject.id}"
    end

    it 'has a title field using the exhibit specific blacklight_config' do
      expect(subject.to_solr['configured_title_field']).to eq 'Title Data'
    end

    it 'has the other additional configured fields' do
      expect(subject.to_solr[:spotlight_upload_description_tesim]).to eq 'Description Data'
      expect(subject.to_solr[:spotlight_upload_attribution_tesim]).to eq 'Attribution Data'
      expect(subject.to_solr[:spotlight_upload_date_tesim]).to eq 'Date Data'
    end

    it 'has a spotlight_resource_type field' do
      expect(subject.to_solr[:spotlight_resource_type_ssim]).to eq 'spotlight/resources/uploads'
    end
    it 'has the various image fields' do
      expect(subject.to_solr).to have_key Spotlight::Engine.config.full_image_field
      expect(subject.to_solr).to have_key Spotlight::Engine.config.thumbnail_field
      expect(subject.to_solr).to have_key Spotlight::Engine.config.square_image_field
    end
    it 'has the full image dimensions fields' do
      expect(subject.to_solr[:spotlight_full_image_height_ssm]).to eq 600
      expect(subject.to_solr[:spotlight_full_image_width_ssm]).to eq 800
    end
    it 'has fields representing exhibit specific custom fields' do
      expect(subject.to_solr[custom_field.solr_field]).to eq 'Custom Field Data'
    end
  end
end
