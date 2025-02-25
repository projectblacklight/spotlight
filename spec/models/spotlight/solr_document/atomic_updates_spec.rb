# frozen_string_literal: true

RSpec.describe Spotlight::SolrDocument::AtomicUpdates, type: :model do
  subject do
    SolrDocument.new.extend(described_class)
  end

  let(:blacklight_solr) { double }

  before do
    allow(subject).to receive_messages(blacklight_solr:)
  end

  describe '#reindex' do
    before do
      allow(subject).to receive_messages(to_solr: { id: 'doc_id', a: 1, b: 2 })
    end

    context 'when the index is not writable' do
      before do
        allow(Spotlight::Engine.config).to receive_messages(writable_index: false)
      end

      it "doesn't write" do
        expect(blacklight_solr).not_to receive(:update)
        subject.reindex
      end
    end

    it 'sends an atomic update request' do
      expected = {
        params: { commitWithin: 500 },
        data: [{ id: 'doc_id', a: { set: 1 }, b: { set: 2 }, timestamp: { set: nil } }].to_json,
        headers: { 'Content-Type' => 'application/json' }
      }
      expect(blacklight_solr).to receive(:update).with(expected)
      subject.reindex
    end

    it 'update parameters can be specified to modify commitWithin' do
      expected = {
        params: { commitWithin: 5001 },
        data: [{ id: 'doc_id', a: { set: 1 }, b: { set: 2 }, timestamp: { set: nil } }].to_json,
        headers: { 'Content-Type' => 'application/json' }
      }
      expect(blacklight_solr).to receive(:update).with(expected)
      subject.reindex(update_params: { commitWithin: 5001 })
    end

    it 'cowardlies refuse to index a document if the only value is an id' do
      allow(subject).to receive_messages(to_solr: { id: 'doc_id' }, timestamp: { set: nil })
      expect(blacklight_solr).not_to receive(:update)
      subject.reindex
    end
  end
end
