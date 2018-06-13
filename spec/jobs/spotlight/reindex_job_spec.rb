describe Spotlight::ReindexJob do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:resource) { FactoryBot.create(:resource) }
  let(:user) { FactoryBot.create(:user) }
  let(:log_entry) { Spotlight::ReindexingLogEntry.create(exhibit: exhibit, user: user) }

  before do
    allow_any_instance_of(Spotlight::Resource).to receive(:reindex)
  end

  context 'with an exhibit' do
    subject { described_class.new(exhibit) }

    before do
      exhibit.resources << resource
      exhibit.save
    end

    it 'attempts to reindex every resource in the exhibit' do
      # ActiveJob will reload the collection, so we go through a little trouble:
      expect_any_instance_of(Spotlight::Resource).to receive(:reindex) do |thingy|
        expect(exhibit.resources).to include thingy
      end

      subject.perform_now
    end

    context 'with a log_entry' do
      subject { described_class.new(exhibit, log_entry) }

      it 'marks the log entry as started' do
        expect(log_entry).to receive(:in_progress!)
        subject.perform_now
      end

      it 'marks the log entry as successful if there is no error' do
        expect(log_entry).to receive(:succeeded!)
        subject.perform_now
      end

      it 'marks the log entry as failed if there is an error' do
        unexpected_error = StandardError.new
        # it'd be more realistic to raise on resource#reindex, but that's already stubbed above, so this'll have to do
        expect(subject).to receive(:perform).with(exhibit, log_entry).and_raise unexpected_error
        expect(log_entry).to receive(:failed!)
        expect { subject.perform_now }.to raise_error unexpected_error
      end

      it 'updates the items_reindexed_estimate field on the log entry' do
        expect(log_entry).to receive(:update).with(items_reindexed_estimate: 1)
        subject.perform_now
      end

      it 'passes log_entry to the resource.reindex call' do
        # ActiveJob will reload the collection, so we go through a little trouble:
        expect_any_instance_of(Spotlight::Resource).to receive(:reindex).with(log_entry).exactly(:once)
        # expect(resource).to receive(:reindex).with(log_entry)
        subject.perform_now
      end
    end
  end

  context 'with a resource' do
    subject { described_class.new(resource) }

    it 'attempts to reindex every resource in the exhibit' do
      expect(resource).to receive(:reindex)
      subject.perform_now
    end
  end
end
