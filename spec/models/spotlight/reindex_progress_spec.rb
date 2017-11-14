describe Spotlight::ReindexProgress, type: :model do
  let(:job_log_entry) do
    FactoryGirl.create(:failed_reindexing_log_entry, job_items_estimate: 12)
  end

  let(:subject) { described_class.new(job_log_entry) }

  describe '#started_at' do
    it 'returns start_time for current_log_entry' do
      expect(subject.started_at).to eq job_log_entry.start_time
    end
  end

  describe '#updated_at' do
    it 'returns the time of last update for current_log_entry' do
      expect(subject.updated_at).to eq job_log_entry.updated_at
    end
  end

  describe '#finished?' do
    it 'returns true if current_log_entry is succeeded or failed' do
      expect(subject.finished?).to be true
    end
  end

  describe '#finished_at' do
    it 'returns end_time for current_log_entry' do
      expect(subject.finished_at).to eq(job_log_entry.end_time)
    end
  end

  describe '#total' do
    it 'returns job_items_estimate for current_log_entry' do
      expect(subject.total).to be 12
    end
  end

  describe '#completed' do
    it 'returns job_item_count for current_log_entry' do
      expect(subject.completed).to be 10
    end
  end

  describe '#errored?' do
    it 'returns true for log entries marked as failed' do
      expect(subject).to be_errored
    end
  end

  describe '#as_json' do
    it 'returns a hash with values for current_log_entry via the various helper methods' do
      expect(subject.as_json).to eq(
        recently_in_progress: subject.recently_in_progress?,
        started_at: I18n.l(job_log_entry.start_time, format: :short),
        finished_at: I18n.l(job_log_entry.end_time, format: :short),
        updated_at: I18n.l(job_log_entry.updated_at, format: :short),
        total: subject.total,
        completed: subject.completed,
        errored: subject.errored?,
        finished: subject.finished?
      )
    end
  end

  describe '#recently_in_progress?' do
    context 'there is no end_time for current_log_entry' do
      let(:job_log_entry) { FactoryGirl.create(:in_progress_reindexing_log_entry) }

      it 'returns true' do
        expect(subject).to be_recently_in_progress
      end
    end

    context 'current_log_entry has an end_time less than Spotlight::Engine.config.reindex_progress_window.minutes.ago' do
      let(:job_log_entry) { FactoryGirl.create(:recent_reindexing_log_entry, end_time: Time.zone.now) }

      it 'returns true' do
        expect(subject).to be_recently_in_progress
      end
    end

    context 'current_log_entry is unstarted ' do
      let(:job_log_entry) { FactoryGirl.create(:unstarted_reindexing_log_entry) }

      it 'returns false' do
        expect(subject).not_to be_recently_in_progress
      end
    end
  end

  context 'current_log_entry is blan' do
    let(:job_log_entry) { Spotlight::JobLogEntry.new }

    # rubocop:disable RSpec/MultipleExpectations
    it 'methods return gracefully' do
      expect(subject.recently_in_progress?).to be false
      expect(subject.started_at).to be nil
      expect(subject.updated_at).to be nil
      expect(subject.finished?).to be false
      expect(subject.finished_at).to be nil
      expect(subject.total).to be nil
      expect(subject.completed).to be nil
      expect(subject.errored?).to be false
      expect(subject.send(:localized_start_time)).to be nil
      expect(subject.send(:localized_finish_time)).to be nil
      expect(subject.send(:localized_updated_time)).to be nil
      expect(subject.as_json).to eq(
        recently_in_progress: false,
        started_at: nil,
        finished_at: nil,
        updated_at: nil,
        total: nil,
        completed: nil,
        errored: false,
        finished: false
      )
    end
    # rubocop:enable RSpec/MultipleExpectations
  end
end
