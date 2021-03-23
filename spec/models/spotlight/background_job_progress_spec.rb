# frozen_string_literal: true

describe Spotlight::BackgroundJobProgress, type: :model do
  subject(:progress) { described_class.new(exhibit, job_class: Spotlight::ReindexExhibitJob) }

  let(:exhibit) { FactoryBot.create(:exhibit) }
  let!(:job_tracker) do
    FactoryBot.create(
      :job_tracker,
      resource: exhibit,
      on: exhibit,
      job_class: 'Spotlight::ReindexExhibitJob',
      updated_at: Time.zone.now,
      **job_tracker_args
    )
  end
  let(:job_tracker_args) { {} }

  context 'with a completed job' do
    let(:job_tracker_args) { { status: 'completed', data: { progress: 50, total: 50 } } }

    it 'reports on reindexing progress' do
      expect(progress.as_json).to include(
        completed: 50,
        total: 50,
        finished: true,
        errored: false,
        recently_in_progress: true
      )
    end
  end

  context 'with a failed job' do
    let(:job_tracker_args) { { status: 'failed', data: { progress: 32, total: 50 } } }

    it 'reports on reindexing progress' do
      expect(progress.as_json).to include(
        completed: 32,
        total: 50,
        finished: true,
        errored: true
      )
    end
  end

  context 'with an in-progress job' do
    before do
      FactoryBot.create(:job_tracker, on: job_tracker, resource: exhibit, data: { progress: 32, total: 32 }, status: 'completed')
      FactoryBot.create(:job_tracker, on: job_tracker, resource: exhibit, data: { progress: 16, total: 50 }, status: 'in_progress')
    end

    let(:job_tracker_args) { { status: 'in_progress' } }

    it 'harvests total and completed data from the child jobs' do
      expect(progress.as_json).to include(
        completed: 48,
        total: 82
      )
    end

    it 'is not completed until all the child jobs are finished' do
      job_tracker.update(status: 'failed')

      expect(progress.as_json).to include(
        finished: false,
        errored: true
      )
    end
  end

  context 'with no job' do
    before do
      job_tracker.delete
    end

    it 'reports on reindexing progress' do
      expect(progress.as_json).to include(
        completed: 0,
        total: 0,
        finished: false,
        errored: false,
        recently_in_progress: false
      )
    end
  end

  context 'with multiple job trackers' do
    let(:job_tracker_args) { { status: 'in_progress' } }

    before do
      FactoryBot.create(
        :job_tracker,
        resource: exhibit,
        on: exhibit,
        job_class: 'Spotlight::ReindexExhibitJob',
        updated_at: Time.zone.now,
        status: 'completed'
      )
    end

    it 'uses the currently in-progress tracker' do
      expect(progress.as_json).to include(finished: false)
    end
  end

  context 'with multiple in-progress trackers' do
    let(:job_tracker_args) { { status: 'in_progress' } }

    before do
      FactoryBot.create(
        :job_tracker,
        resource: exhibit,
        on: exhibit,
        job_class: 'Spotlight::ReindexExhibitJob',
        updated_at: Time.zone.now - 5.years,
        status: 'in_progress'
      )
    end

    it 'uses the most recently updated tracker' do
      expect(Time.zone.parse(progress.as_json[:updated_at]).year).to eq job_tracker.updated_at.year
    end
  end
end
