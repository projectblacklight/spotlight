describe Spotlight::FeaturedImage do
  subject(:featured_image) { described_class.new }

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
