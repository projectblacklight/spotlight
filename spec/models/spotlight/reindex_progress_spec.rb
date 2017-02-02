describe Spotlight::ReindexProgress, type: :model do
  let(:reindexing_log_entries) do
    [
      # failed is the later of the two, and thus the return value for current_log_entry
      FactoryGirl.create(:reindexing_log_entry, items_reindexed_estimate: 11),
      FactoryGirl.create(:failed_reindexing_log_entry, items_reindexed_estimate: 12)
    ]
  end
  let(:exhibit) { FactoryGirl.create(:exhibit, reindexing_log_entries: reindexing_log_entries) }

  let(:subject) { described_class.new(exhibit) }

  describe '#started_at' do
    it 'returns start_time for current_log_entry' do
      expect(subject.started_at).to eq(Time.zone.parse('2017-01-10 23:00:00'))
    end
  end

  describe '#updated_at' do
    # disable SkipsModelValidations cop for this test, because it complains about #touch, which is convenient here
    # rubocop:disable Rails/SkipsModelValidations
    it 'returns the time of last update for current_log_entry' do
      lower_bound = Time.zone.now
      subject.send(:current_log_entry).touch
      upper_bound = Time.zone.now

      expect(subject.updated_at).to be_between(lower_bound, upper_bound)
    end
    # rubocop:enable Rails/SkipsModelValidations
  end

  describe '#finished?' do
    it 'returns true if current_log_entry is succeeded or failed' do
      expect(subject.finished?).to be true
    end
  end

  describe '#finished_at' do
    it 'returns end_time for current_log_entry' do
      expect(subject.finished_at).to eq(Time.zone.parse('2017-01-10 23:05:00'))
    end
  end

  describe '#total' do
    it 'returns items_reindexed_estimate for current_log_entry' do
      expect(subject.total).to be 12
    end
  end

  describe '#completed' do
    it 'returns items_reindexed_count for current_log_entry' do
      expect(subject.completed).to be 10
    end
  end

  describe '#errored?' do
    it 'returns true for log entries marked as failed' do
      expect(subject.errored?).to be true
    end
  end

  describe '#as_json' do
    it 'returns a hash with values for current_log_entry via the various helper methods' do
      expect(subject.as_json).to eq(
        recently_in_progress: subject.recently_in_progress?,
        started_at: subject.send(:localized_start_time),
        finished_at: subject.send(:localized_finish_time),
        updated_at: subject.send(:localized_updated_time),
        total: subject.total,
        completed: subject.completed,
        errored: subject.errored?,
        finished: subject.finished?
      )
    end
  end

  describe '#recently_in_progress?' do
    context 'there is no end_time for current_log_entry' do
      let(:current_log_entry) { FactoryGirl.create(:in_progress_reindexing_log_entry) }
      let(:exhibit) { FactoryGirl.create(:exhibit, reindexing_log_entries: [current_log_entry]) }

      it 'returns true' do
        expect(subject.recently_in_progress?).to be true
      end
    end

    context 'current_log_entry has an end_time less than Spotlight::Engine.config.reindex_progress_window.minutes.ago' do
      let(:current_log_entry) { FactoryGirl.create(:recent_reindexing_log_entry, end_time: Time.zone.now) }
      let(:exhibit) { FactoryGirl.create(:exhibit, reindexing_log_entries: [current_log_entry]) }

      it 'returns true' do
        expect(subject.recently_in_progress?).to be true
      end
    end

    context 'current_log_entry is unstarted ' do
      let(:current_log_entry) { FactoryGirl.create(:unstarted_reindexing_log_entry) }
      let(:exhibit) { FactoryGirl.create(:exhibit, reindexing_log_entries: [current_log_entry]) }

      it 'returns false' do
        expect(subject.recently_in_progress?).to be false
      end
    end
  end

  describe 'private methods' do
    describe '#current_log_entry' do
      let(:reindexing_log_entries) do
        [
          FactoryGirl.create(:unstarted_reindexing_log_entry),
          FactoryGirl.create(:reindexing_log_entry),
          FactoryGirl.create(:in_progress_reindexing_log_entry),
          FactoryGirl.create(:failed_reindexing_log_entry),
          FactoryGirl.create(:unstarted_reindexing_log_entry)
        ]
      end

      it 'returns the latest log entry that is not unstarted' do
        expect(subject.send(:current_log_entry)).to eq(reindexing_log_entries[2])
      end
    end

    describe '#localized_start_time' do
      it 'returns the short formatted start time' do
        expect(subject.send(:localized_start_time)).to eq I18n.l(subject.started_at, format: :short)
      end
    end

    describe '#localized_finish_time' do
      it 'returns the short formatted end time' do
        expect(subject.send(:localized_finish_time)).to eq I18n.l(subject.finished_at, format: :short)
      end
    end

    describe '#localized_updated_time' do
      it 'returns the short formatted last updated time' do
        expect(subject.send(:localized_updated_time)).to eq I18n.l(subject.updated_at, format: :short)
      end
    end
  end

  context 'current_log_entry is nil' do
    let(:reindexing_log_entries) { [] }

    # rubocop:disable RSpec/MultipleExpectations
    it 'methods return gracefully' do
      expect(subject.send(:current_log_entry)).to be nil

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
