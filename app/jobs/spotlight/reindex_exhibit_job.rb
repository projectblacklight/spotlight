# frozen_string_literal: true

module Spotlight
  ##
  # Reindex an exhibit by parallelizing resource indexing into multiple batches of reindex jobs
  class ReindexExhibitJob < Spotlight::ApplicationJob
    include Spotlight::JobTracking

    with_job_tracking(resource: ->(job) { job.arguments.first })

    include Spotlight::LimitConcurrency

    def perform(exhibit, batch_size: Spotlight::Engine.config.reindexing_batch_size, batch_count: Spotlight::Engine.config.reindexing_batch_count, **)
      count = exhibit.resources.count

      # Use the provided batch size, or calculate a reasonable default
      batch_count = (count.to_f / batch_size).ceil if batch_size
      batch_count ||= batch_count_based_on_number_of_resources(count)

      return Spotlight::ReindexJob.perform_now(exhibit, reports_on: job_tracker) if batch_count == 1

      batch_size ||= (count.to_f / batch_count).ceil

      perform_later_in_batches(exhibit, of: batch_size)

      # mark the job as 'pending' and let the UpdateJobTrackersJob finalize this status after the ReindexJobs finish
      job_tracker.update(status: 'pending')
    end

    private

    def perform_later_in_batches(exhibit, of:)
      last = 0
      exhibit.resources.select(:id).in_batches(of:) do |batch|
        last = batch.last.id
        Spotlight::ReindexJob.perform_later(exhibit, reports_on: job_tracker, start: batch.first.id, finish: batch.last.id)
      end

      Spotlight::ReindexJob.perform_later(exhibit, reports_on: job_tracker, start: last)
    end

    def batch_count_based_on_number_of_resources(count)
      return 1 if count.zero?

      1 + Math.log(count).round # e.g. 10 => 3, 100 => 6, 1000 => 8
    end
  end
end
