# frozen_string_literal: true

RSpec.describe Spotlight::CleanupJobTrackersJob do
  let!(:recent_completed) { FactoryBot.create(:job_tracker, status: 'completed', updated_at: 30.minutes.ago) }
  let!(:old_failed) { FactoryBot.create(:job_tracker, status: 'failed', updated_at: 2.hours.ago) }
  let!(:old_in_progress) { FactoryBot.create(:job_tracker, status: 'in_progress', updated_at: 2.hours.ago) }

  before do
    FactoryBot.create(:job_tracker, status: 'completed', updated_at: 2.hours.ago)
  end

  it 'deletes completed job trackers last updated before the reindex progress window' do
    described_class.perform_now

    expect(Spotlight::JobTracker.all).to contain_exactly(recent_completed, old_failed, old_in_progress)
  end
end
