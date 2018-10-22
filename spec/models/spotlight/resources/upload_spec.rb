describe Spotlight::Resources::Upload, type: :model do
  let!(:exhibit) { FactoryBot.create :exhibit }
  let!(:custom_field) { FactoryBot.create :custom_field, exhibit: exhibit }
  let(:resource) { described_class.new(exhibit: exhibit) }
  let(:doc_builder) { resource.document_builder }

  let(:configured_fields) { [title_field] + described_class.fields(exhibit) }
  let(:title_field) { Spotlight::UploadFieldConfig.new(field_name: 'configured_title_field') }
  let(:upload_data) do
    {
      title_field.field_name => 'Title Data',
      'spotlight_upload_description_tesim' => 'Description Data',
      'spotlight_upload_attribution_tesim' => 'Attribution Data',
      'spotlight_upload_date_tesim' => 'Date Data',
      custom_field.field => 'Custom Field Data'
    }
  end
  let(:featured_image) { FactoryBot.create(:featured_image, image: File.open(File.join(FIXTURES_PATH, '800x600.png'))) }

  before do
    Rails.cache.clear # wipes out any cached image info.
    allow(resource).to receive(:configured_fields).and_return configured_fields
    allow(described_class).to receive(:fields).and_return configured_fields

    allow(resource.send(:blacklight_solr)).to receive(:update)
    allow(Spotlight::Engine.config).to receive(:upload_title_field).and_return(title_field)
    resource.data = upload_data
    resource.upload = featured_image
    resource.save
  end

  context 'with a custom upload title field' do
    let(:title_field) { Spotlight::UploadFieldConfig.new(field_name: 'configured_title_field', solr_fields: [:some_other_field]) }
    subject { doc_builder.to_solr }

    describe '#to_solr' do
      it 'stores the title field in the provided solr field' do
        expect(subject[:some_other_field]).to eq 'Title Data'
      end
    end
  end

  context 'multiple solr field mappings' do
    let :configured_fields do
      [
        Spotlight::UploadFieldConfig.new(field_name: 'some_field', solr_fields: %w(a b))
      ]
    end

    let :upload_data do
      { 'some_field' => 'value' }
    end

    describe '#to_solr' do
      subject { doc_builder.to_solr }

      it 'maps a single uploaded field to multiple solr fields' do
        expect(subject).not_to include 'some_field'
        expect(subject['a']).to eq 'value'
        expect(subject['b']).to eq 'value'
      end
    end
  end

  describe '#to_solr' do
    subject { doc_builder.to_solr }

    it 'has the exhibit id and the upload id as the solr id' do
      expect(subject[:id]).to eq "#{resource.exhibit.id}-#{resource.id}"
    end

    it 'has a title field using the exhibit specific blacklight_config' do
      expect(subject['configured_title_field']).to eq 'Title Data'
    end

    it 'has the other additional configured fields' do
      expect(subject[:spotlight_upload_description_tesim]).to eq 'Description Data'
      expect(subject[:spotlight_upload_attribution_tesim]).to eq 'Attribution Data'
      expect(subject[:spotlight_upload_date_tesim]).to eq 'Date Data'
    end

    it 'has a spotlight_resource_type field' do
      expect(subject[:spotlight_resource_type_ssim]).to eq 'spotlight/resources/uploads'
    end
    it 'has the various image fields' do
      expect(subject).to have_key Spotlight::Engine.config.thumbnail_field
    end
    it 'has the full image dimensions fields' do
      expect(subject[:spotlight_full_image_height_ssm]).to eq 600
      expect(subject[:spotlight_full_image_width_ssm]).to eq 800
    end
    it 'has fields representing exhibit specific custom fields' do
      expect(subject[custom_field.solr_field]).to eq 'Custom Field Data'
    end
    it 'has a field for the iiif manifest url' do
      manifest_path = Spotlight::Engine.routes.url_helpers.manifest_exhibit_solr_document_path(exhibit, resource.compound_id)
      expect(subject[Spotlight::Engine.config.iiif_manifest_field]).to eq(manifest_path)
    end
  end
end
