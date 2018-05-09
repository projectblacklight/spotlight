describe Spotlight::JobLogEntry, type: :model do
  subject { FactoryBot.build(:job_log_entry) }

  describe 'scope' do
    before do
      (0..10).to_a.each { FactoryBot.create(:recent_job_log_entry) }
      FactoryBot.create(:unstarted_job_log_entry)
      (0..10).to_a.each { FactoryBot.create(:recent_job_log_entry) }
    end

    let(:sorted_log_entry_list) do
      unstarted_entries = Spotlight::JobLogEntry.where(start_time: nil).to_a
      started_entries = Spotlight::JobLogEntry.where.not(start_time: nil).to_a.sort_by(&:start_time).reverse
      unstarted_entries + started_entries # null start times should be first
    end

    context 'default' do
      it 'sorts by start_time in descending order' do
        default_log_entry_list = Spotlight::JobLogEntry.all.to_a
        expect(default_log_entry_list).to eq sorted_log_entry_list
      end
    end

    context 'recent' do
      it 'returns the most recent 5 entries (sorted by start_time descending)' do
        recent_log_entry_list = Spotlight::JobLogEntry.recent.to_a
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
      subject { FactoryBot.build(:in_progress_job_log_entry) }

      it 'is nil' do
        expect(subject.duration).to be nil
      end
    end
  end

  describe '#job_type' do
    context 'when reindexing' do
      it 'sets the job type to Reindexing' do
        expect(subject.job_type).to eq 'Reindexing'
      end
    end

    context 'when not reindexing' do
      subject { FactoryBot.build(:in_progress_alternative_log_entry) }

      it 'sets the job type to a user defined type' do
        expect(subject.job_type).to eq 'alternative'
      end
    end
  end

  describe 'state updating methods' do
    describe '#in_progress!' do
      subject { FactoryBot.build(:unstarted_job_log_entry) }

      context 'executes normally' do
        it 'sets start_time and job_status' do
          lower_time_bound = Time.zone.now
          subject.in_progress!
          upper_time_bound = Time.zone.now

          expect(subject.start_time).to be_between(lower_time_bound, upper_time_bound)
          expect(subject.job_status).to eq 'in_progress'
        end
      end

      context 'encounters an unexpected error' do
        it "traps the exception and logs an error so that the caller doesn't have to deal with it" do
          expect(subject).to receive(:'start_time=').and_raise StandardError.new # try to blow up the in_progress! call
          expect(Rails.logger).to receive(:error) do |arg|
            expect(arg).to start_with('unexpected error updating log entry to :in_progress from')
          end

          expect { subject.in_progress! }.not_to raise_error
        end
      end
    end

    describe '#succeeded!' do
      subject { FactoryBot.build(:in_progress_job_log_entry) }

      context 'executes normally' do
        it 'sets end_time and job_status' do
          lower_time_bound = Time.zone.now
          subject.succeeded!
          upper_time_bound = Time.zone.now

          expect(subject.end_time).to be_between(lower_time_bound, upper_time_bound)
          expect(subject.job_status).to eq 'succeeded'
        end
      end

      context 'encounters an unexpected error' do
        it "traps the exception and logs an error so that the caller doesn't have to deal with it" do
          expect(subject).to receive(:'end_time=').and_raise StandardError.new # try to blow up the succeeded! call
          expect(Rails.logger).to receive(:error) do |arg|
            expect(arg).to start_with('unexpected error updating log entry to :succeeded from')
          end

          expect { subject.succeeded! }.not_to raise_error
        end
      end
    end

    describe '#failed!' do
      subject { FactoryBot.build(:in_progress_job_log_entry) }

      context 'executes normally' do
        it 'sets end_time and job_status' do
          lower_time_bound = Time.zone.now
          subject.failed!
          upper_time_bound = Time.zone.now

          expect(subject.end_time).to be_between(lower_time_bound, upper_time_bound)
          expect(subject.job_status).to eq 'failed'
        end
      end

      context 'encounters an unexpected error' do
        it "traps the exception and logs an error so that the caller doesn't have to deal with it" do
          expect(subject).to receive(:'end_time=').and_raise StandardError.new # try to blow up the failed! call
          expect(Rails.logger).to receive(:error) do |arg|
            expect(arg).to start_with('unexpected error updating log entry to :failed from')
          end

          expect { subject.failed! }.not_to raise_error
        end
      end
    end
  end
end
