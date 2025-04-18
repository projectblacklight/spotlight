# frozen_string_literal: true

RSpec.describe Spotlight::FeaturedImage do
  subject(:featured_image) { described_class.new }

  let(:temp_image) { FactoryBot.create(:temporary_image) }

  describe '#bust_containing_resource_caches' do
    let!(:feature_page) { FactoryBot.create(:feature_page, thumbnail: temp_image) }
    let!(:feature_page2) { FactoryBot.create(:feature_page, thumbnail: temp_image) }

    it 'changes the updated_at for all resources that might be using this image' do
      temp_image.save

      expect(feature_page.updated_at).to be < feature_page.reload.updated_at
      expect(feature_page2.updated_at).to be < feature_page2.reload.updated_at
    end
  end

  context 'with an uploaded image' do
    it 'copies the temporary uploaded image to this model' do
      featured_image.source = 'remote'
      featured_image.upload_id = temp_image.id

      featured_image.save

      expect(featured_image.image.filename).to eq temp_image.image.filename
      expect(featured_image.image.read).to eq temp_image.image.read

      expect { temp_image.reload }.to raise_exception ActiveRecord::RecordNotFound
    end
  end

  describe '#iiif_url' do
    let(:iiif_tilesource) { 'http://example.com/iiif/abc123/info.json' }
    let(:iiif_region) { '0,0,400,300' }

    describe 'tilesource' do
      it 'is nil when not present' do
        expect(subject.iiif_url).to be_nil
      end

      it 'is included when present (without "/info.json")' do
        subject.iiif_tilesource = iiif_tilesource
        expect(subject.iiif_url).to match(%r{^http://example.com/iiif/abc123/})
        expect(subject.iiif_url).not_to include('info.json')
      end

      context 'with an uploaded image' do
        before do
          featured_image.image = temp_image.image
          featured_image.save!
        end

        it 'points at the RIIIF endpoint' do
          expect(subject.iiif_url).to match(%r{^/images/\d+-.+/})
        end
      end
    end

    describe 'region' do
      before { subject.iiif_tilesource = iiif_tilesource }

      it 'is included when present' do
        subject.iiif_region = iiif_region
        expect(subject.iiif_url).to match(%r{/abc123/#{iiif_region}/})
      end

      it 'is "full" when not present' do
        expect(subject.iiif_url).to match(%r{/abc123/full/})
      end
    end
  end

  describe '#document' do
    before { subject.source = 'exhibit' }

    it 'fetches the document given the stored GlobalID' do
      subject.document_global_id = 'gid://internal/SolrDocument/yn959jw9550'

      expect(subject.document).to be_a SolrDocument
      expect(subject.document[:id]).to eq 'yn959jw9550'
    end

    it 'busts memoization if the GlobalID is updated' do
      subject.document_global_id = 'gid://internal/SolrDocument/yn959jw9550'
      expect(subject.document[:id]).to eq 'yn959jw9550'

      subject.document_global_id = 'gid://internal/SolrDocument/gk446cj2442'
      expect(subject.document[:id]).to eq 'gk446cj2442'
    end

    it 'returns nil if the document cannot be found via GlobalID' do
      subject.document_global_id = 'gid://internal/SolrDocument/NotARealDoc'

      expect(subject.document).to be_nil
    end
  end

  describe '#file_present?' do
    it 'is false when the image file is not present' do
      expect(subject.file_present?).to be false
    end

    it 'is true when the image file is present' do
      expect(subject).to receive(:image).and_return(double('CarrierWaveUpload', file: 'uploaded file content'))
      expect(subject.file_present?).to be true
    end
  end
end
