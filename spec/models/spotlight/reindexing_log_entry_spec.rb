describe Spotlight::ReindexingLogEntry, type: :model do
  subject { FactoryGirl.build(:reindexing_log_entry) }

  describe 'scope' do
    before(:all) do
      # we only want to persist these rows for the duration a given test run...
      DatabaseCleaner.start
      # create (and save) entries in the log that can be queried, so that we can test our scopes
      (0..10).to_a.each { FactoryGirl.create(:recent_reindexing_log_entry) }
      FactoryGirl.create(:unstarted_reindexing_log_entry)
      (0..10).to_a.each { FactoryGirl.create(:recent_reindexing_log_entry) }
    end

    after(:all) do
      # ...remove the entries we created, now that we're done with them
      DatabaseCleaner.clean
    end

    let(:sorted_log_entry_list) do
      unstarted_entries = Spotlight::ReindexingLogEntry.where(start_time: nil).to_a
      started_entries = Spotlight::ReindexingLogEntry.where.not(start_time: nil).to_a.sort_by(&:start_time).reverse
      unstarted_entries + started_entries # null start times should be first
    end

    context 'default' do
      it 'sorts by start_time in descending order' do
        default_log_entry_list = Spotlight::ReindexingLogEntry.all.to_a
        expect(default_log_entry_list).to eq sorted_log_entry_list
      end
    end

    context 'recent' do
      it 'returns the most recent 5 entries (sorted by start_time descending)' do
        recent_log_entry_list = Spotlight::ReindexingLogEntry.recent.to_a
        expect(recent_log_entry_list).to eq sorted_log_entry_list[0..4]
      end
    end
  end

  describe '#duration' do
    context 'when end_time is present' do
      it 'is calculated as difference between end_time and start_time' do
        expect(subject.duration).to eq 300
      end
    end

    context 'when end_time is not present' do
      subject { FactoryGirl.build(:in_progress_reindexing_log_entry) }

      it 'is nil' do
        expect(subject.duration).to be nil
      end
    end
  end
end
