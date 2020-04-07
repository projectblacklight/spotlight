# frozen_string_literal: true

describe Spotlight::Resources::Upload, type: :model do
  subject(:upload) { described_class.new(id: 42, exhibit: exhibit) }

  let(:exhibit) { FactoryBot.create(:exhibit) }

  describe '.fields' do
    it "includes the exhibit's uploaded resource fields" do
      expect(described_class.fields(exhibit)).to include(*exhibit.uploaded_resource_fields)
    end

    context 'title field' do
      it 'is an UploadFieldConfig object for the configured index title_field' do
        upload_config = described_class.fields(exhibit).first
        expect(upload_config).to be_a Spotlight::UploadFieldConfig
        expect(upload_config.field_name).to eq exhibit.blacklight_config.index.title_field
      end
    end
  end

  describe '#compound_id' do
    it 'appends the object ID w/ the exhibit ID' do
      expect(upload.compound_id).to eq "#{exhibit.id}-42"
    end
  end

  describe '#sidecar' do
    it 'is a SolrDocumentSidecar with the correct relationships' do
      sidecar = upload.sidecar

      expect(sidecar).to be_a Spotlight::SolrDocumentSidecar
      expect(sidecar.exhibit_id).to eq exhibit.id
      expect(sidecar.document_id).to eq "#{exhibit.id}-42"
    end
  end

  context 'when creating' do
    before do
      allow(upload).to receive(:write?).and_return(false)
    end

    it 'the sidecar is updated with the apporpriate data from configured fields' do
      expect(upload.sidecar).to receive(:update).with(
        data: {
          'configured_fields' => {
            'full_title_tesim' => 'My Upload Title',
            'spotlight_upload_date_tesim' => 'My Upload Date'
          }
        }
      )

      upload.data = { 'full_title_tesim' => 'My Upload Title', 'spotlight_upload_date_tesim' => 'My Upload Date' }

      upload.save
    end

    it 'the sidecar is updated with the appropriate data from custom fields' do
      FactoryBot.create(:custom_field, exhibit: exhibit, slug: 'custom_field_1')
      FactoryBot.create(:custom_field, exhibit: exhibit, slug: 'custom_field_2')

      expect(upload.sidecar).to receive(:update).with(
        data: hash_including('custom_field_1' => 'Custom Field 1 Data', 'custom_field_2' => 'Custom Field 2 Data')
      )

      upload.data = { 'custom_field_1' => 'Custom Field 1 Data', 'custom_field_2' => 'Custom Field 2 Data' }

      upload.save
    end
  end
end
