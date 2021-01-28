# frozen_string_literal: true

module Spotlight
  ##
  # Reindex an exhibit by parallelizing resource indexing into multiple batches of reindex jobs
  class ReindexExhibitJob < Spotlight::ApplicationJob
    include Spotlight::JobTracking
    include Spotlight::LimitConcurrency

    def perform(exhibit, batch_size: nil, batch_count: nil, **)
      job_tracker.update(status: 'in_progress')

      count = exhibit.resources.count

      # Use the provided batch size, or calculate a reasonable default
      batch_count = (count.to_f / batch_size).ceil if batch_size
      batch_count ||= 1 + Math.log(count).round # e.g. 10 => 3, 100 => 6, 1000 => 8

      batch_size ||= (count.to_f / batch_count).ceil

      batch_count.times do |i|
        Spotlight::ReindexJob.perform_later(exhibit, reports_on: job_tracker, per: batch_size, page: i + 1)
      end

      # and one extra to catch any late additions
      Spotlight::ReindexJob.perform_later(exhibit, reports_on: job_tracker, per: batch_size, page: batch_count + 1, last: true)
    end
  end
end
