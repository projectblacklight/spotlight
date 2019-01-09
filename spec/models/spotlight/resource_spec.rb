describe Spotlight::Resource, type: :model do
  before do
    allow_any_instance_of(described_class).to receive(:update_index)
  end

  let(:exhibit) { FactoryBot.create(:exhibit) }

  describe '#reindex' do
    context 'with a provider that generates ids' do
      subject do
        Class.new(described_class).new(exhibit: exhibit)
      end

      let(:solr_response) { { id: 123 } }

      before do
        SolrDocument.new(id: 123).sidecars.create!(exhibit: exhibit, data: { document_data: true })
        allow(subject).to receive_messages(to_global_id: '')

        allow(subject.document_builder).to receive(:to_solr).and_return(solr_response)
      end

      it 'includes exhibit document-specific data' do
        allow(subject.send(:blacklight_solr)).to receive(:update) do |options|
          data = JSON.parse(options[:data], symbolize_names: true)

          expect(data.length).to eq 1
          doc = data.first

          break if doc.first == :commit

          expect(doc).to include document_data: true
        end

        subject.reindex
      end

      context 'when a document does not have an identifier' do
        let(:solr_response) { { other_field: 'Content' } }

        it 'is not indexed (but a commit can be sent)' do
          allow(subject.send(:blacklight_solr)).to receive(:commit)
          expect(subject.send(:blacklight_solr)).not_to receive(:update)

          subject.reindex
        end
      end

      context 'job_log_entry is provided' do
        before do
          allow(subject.send(:blacklight_solr)).to receive(:update)
        end

        it 'updates the count of reindexed items in the log entry' do
          job_log_entry = double(Spotlight::JobLogEntry)
          expect(job_log_entry).to receive(:update).with(job_item_count: 1)
          subject.reindex job_log_entry
        end
      end

      context 'when the index is not writable' do
        before do
          allow(Spotlight::Engine.config).to receive_messages(writable_index: false)
        end

        it "doesn't write" do
          expect(subject.send(:blacklight_solr)).not_to receive(:update)
          subject.reindex
        end
      end

      context 'with a resource that creates multiple solr documents' do
        let(:solr_response) { [{ id: 1 }, { id: 2 }] }

        before do
          allow(subject.send(:blacklight_solr)).to receive(:update)
        end

        it 'returns the number of indexed objects' do
          expect(subject.reindex).to eq 2
        end

        it 'triggers a solr commit' do
          expect(subject.send(:blacklight_solr)).to receive(:commit).once

          subject.reindex
        end

        it 'touches the exhibit to clear any caches' do
          allow(subject.exhibit).to receive(:touch)

          subject.reindex

          expect(subject.exhibit).to have_received(:touch)
        end
      end
    end
  end

  describe '#save_and_index' do
    before do
      allow(subject.send(:blacklight_solr)).to receive(:update)
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

    context 'if the save fails' do
      it 'does not reindex' do
        expect(subject).to receive(:save).and_return(false)
        expect(subject).not_to receive(:reindex_later)
        subject.save_and_index
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
