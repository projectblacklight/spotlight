# frozen_string_literal: true

RSpec.describe Spotlight::ReindexExhibitJob do
  let(:exhibit) { FactoryBot.create(:exhibit) }

  before do
    FactoryBot.create_list(:resource, 10, exhibit:)
    allow(Spotlight::ReindexJob).to receive(:perform_now)
    allow(Spotlight::ReindexJob).to receive(:perform_later)
  end

  context 'with a single batch' do
    it 'runs the index job inline' do
      described_class.perform_now(exhibit, batch_count: 1)

      expect(Spotlight::ReindexJob).to have_received(:perform_now).once.with(exhibit, anything)
    end
  end

  context 'with a fixed batch count' do
    it 'enqueues that number of batches' do
      described_class.perform_now(exhibit, batch_count: 2)

      expect(Spotlight::ReindexJob).to have_received(:perform_later).twice.with(exhibit, hash_including(:start, :finish))
    end
  end

  context 'with a dynamically generated batch count' do
    it 'enqueues the right number of batches' do
      described_class.perform_now(exhibit, batch_count: nil, batch_size: 2)

      expect(Spotlight::ReindexJob).to have_received(:perform_later).exactly(5).times.with(exhibit, hash_including(:start, :finish))
    end
  end

  context 'with a dynamically generated batch size' do
    it 'figues out that number of batches' do
      described_class.perform_now(exhibit, batch_count: nil, batch_size: nil)

      expect(Spotlight::ReindexJob).to have_received(:perform_later).exactly(3).times.with(exhibit, hash_including(:start, :finish))
    end
  end
end
