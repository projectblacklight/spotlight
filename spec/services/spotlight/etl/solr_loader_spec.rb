# frozen_string_literal: true

describe Spotlight::Etl::SolrLoader do
  subject(:loader) { described_class.new(batch_size: 5, solr_connection: mock_connection) }

  let(:mock_connection) { instance_double(RSolr::Client, commit: nil, update: nil) }

  describe '#call' do
    it 'queues data' do
      loader.call({})
      loader.call({})
      loader.call({})

      expect(loader.size).to eq 3
    end

    it 'writes data to the index when the queue is long enough' do
      5.times { loader.call({}) }

      expect(mock_connection).to have_received(:update) do |data:, **|
        expect(JSON.parse(data).length).to eq 5
      end
    end
  end

  describe '#finalize' do
    let(:pipeline) do
      Spotlight::Etl::Executor.new(nil, Spotlight::Etl::Context.new(commit: false))
    end

    it 'flushes the remaining queue to the index' do
      3.times { loader.call({}) }

      loader.finalize

      expect(mock_connection).to have_received(:update) do |data:, **|
        expect(JSON.parse(data).length).to eq 3
      end

      expect(mock_connection).to have_received(:commit)
    end

    it 'uses the pipeline configuration to determine whether to send a commit' do
      loader.finalize(pipeline)

      expect(mock_connection).not_to have_received(:commit)
    end

    context 'error handling' do
      it 'tries documents individually if the whole batch fails' do
        allow(mock_connection).to receive(:update) do |data:, **|
          raise '???' if JSON.parse(data).length > 1
        end

        3.times { loader.call({}) }
        loader.finalize

        expect(mock_connection).to have_received(:update).exactly(4).times
      end

      it 'logs errors from trying individual documents' do
        allow(pipeline).to receive(:on_error)

        allow(mock_connection).to receive(:update) do |**|
          raise '???'
        end

        loader.call({})

        loader.finalize(pipeline)

        expect(pipeline).to have_received(:on_error).once
      end
    end
  end
end
