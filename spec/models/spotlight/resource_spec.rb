# frozen_string_literal: true

describe Spotlight::Resource, type: :model do
  subject(:resource) { described_class.create(id: 123, exhibit: exhibit) }

  let(:exhibit) { FactoryBot.create(:exhibit) }

  describe '#save_and_index' do
    before do
      allow(subject).to receive(:save)
      allow(subject).to receive(:reindex_later)
    end

    it 'saves the object' do
      expect(subject).to receive(:save).and_return(true)
      subject.save_and_index
    end

    it 'reindexes after save' do
      expect(subject).to receive(:save).and_return(true)
      expect(subject).to receive(:reindex_later)
      subject.save_and_index
    end

    it 'passes through reindexing options' do
      expect(subject).to receive(:save).and_return(true)
      expect(subject).to receive(:reindex_later).with(a: 1)
      subject.save_and_index(reindex_options: { a: 1 })
    end

    context 'if the save fails' do
      it 'does not reindex' do
        expect(subject).to receive(:save).and_return(false)
        expect(subject).not_to receive(:reindex_later)
        subject.save_and_index
      end
    end
  end

  describe '#reindex_later' do
    around do |block|
      old = ActiveJob::Base.queue_adapter
      begin
        ActiveJob::Base.queue_adapter = :test

        block.call
      ensure
        ActiveJob::Base.queue_adapter = old
      end
    end

    it 'passes through reindexing options' do
      expect { subject.reindex_later(whatever: true) }.to have_enqueued_job(Spotlight::ReindexJob).with(subject, whatever: true, 'validity_token' => nil)
    end
  end

  describe '#reindex' do
    before do
      # sneak some data into the pipeline
      subject.indexing_pipeline.transforms = [->(*) { { id: '123' } }] + subject.indexing_pipeline.transforms
    end

    let(:indexed_document) do
      result = nil

      subject.reindex(**index_args) do |data, *|
        result = data

        # skip actually indexing the document into the solr index
        throw :skip
      end

      result
    end

    let(:index_args) { {} }

    it 'returns the number of items indexed' do
      expect(subject.reindex { |*| throw :skip }).to eq 1
    end

    it 'applies exhibit-specific metadata from the sidecar' do
      expect(indexed_document).to include Spotlight::SolrDocumentSidecar.new(document: SolrDocument.new(id: '123'), exhibit: exhibit).to_solr
    end

    it 'includes metata from each sidecar' do
      a = Spotlight::SolrDocumentSidecar.create(document: SolrDocument.new(id: '123'), exhibit: exhibit)
      b = Spotlight::SolrDocumentSidecar.create(document: SolrDocument.new(id: '123'), exhibit: FactoryBot.build(:exhibit))

      expect(indexed_document).to include(a.to_solr).and(include(b.to_solr))
    end

    it 'persists a sidecar document' do
      expect { indexed_document }.to change(Spotlight::SolrDocumentSidecar, :count).by(1)

      expect(Spotlight::SolrDocumentSidecar.last).to have_attributes(document_id: '123', exhibit: exhibit)
    end

    it 'applies application metadata' do
      expect(indexed_document).to include(spotlight_resource_id_ssim: resource.to_global_id.to_s, spotlight_resource_type_ssim: 'spotlight/resources')
    end

    context 'with some provided metadata' do
      let(:index_args) { { additional_metadata: { a: 1 } } }

      it 'applies externally provided metadata' do
        expect(indexed_document).to include a: 1
      end
    end

    it 'touches the exhibit to bust any caches' do
      allow(exhibit).to receive(:touch)

      indexed_document

      expect(exhibit).to have_received(:touch)
    end

    context 'with touch: false' do
      it 'does not touch the exhibit' do
        allow(exhibit).to receive(:touch)

        expect(subject.reindex(touch: false) { |*| throw :skip }).to eq 1

        expect(exhibit).not_to have_received(:touch)
      end
    end
  end

  it 'stores arbitrary data' do
    subject.data[:a] = 1
    subject.data[:b] = 2

    expect(subject.data[:a]).to eq 1
    expect(subject.data[:b]).to eq 2
  end
end
