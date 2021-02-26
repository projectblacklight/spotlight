# frozen_string_literal: true

module Spotlight
  # Associate background jobs with records
  class JobTracker < ActiveRecord::Base
    scope :recent, -> { order('updated_at DESC').limit(5) }
    scope :in_progress, -> { where.not(status: %w[completed failed]) }
    scope :completed, -> { where(status: %w[completed failed]) }

    belongs_to :on, polymorphic: true
    belongs_to :resource, polymorphic: true
    belongs_to :user, optional: true, class_name: Spotlight::Engine.config.user_class # rubocop:disable Rails/ReflectionClassName
    has_many :events, as: :resource, dependent: :delete_all
    has_many :job_trackers, as: :on, dependent: Rails.version > '6.1' ? :destroy_async : :destroy
    has_many :subevents, through: :job_trackers, source: :events

    serialize :data

    after_initialize do
      self.data ||= {}
    end

    after_commit do
      next unless on.is_a? Spotlight::JobTracker

      UpdateJobTrackersJob.perform_later(self)
    end

    def label
      "[#{job_class.titleize}] #{resource_label}"
    end

    def resource_label
      return resource.filename if resource.is_a? ActiveStorage::Blob
      return resource.name if resource.is_a? Upload

      resource_id
    end

    def job_status
      return {} unless job_id

      @job_status ||= ActiveJob::Status.get(job_id)
    end

    def progress_label
      return number_with_delimiter(progress) unless total?

      "#{number_with_delimiter(progress)} / #{number_with_delimiter(total)}"
    end

    def progress
      data[:progress] || job_status[:progress] || 0
    end

    def total(default: progress)
      [progress, data[:total] || job_status[:total] || default].max
    end

    def total?
      total(default: 0).positive?
    end

    def percent
      return nil unless total?

      (100.0 * progress) / total
    end

    def status
      @status ||= super
      @status ||= 'missing'
      @status = 'in_progress' if @status == 'completed' && job_trackers.any? { |t| t.in_progress? || t.enqueued? }

      @status
    end

    def enqueued?
      status == 'enqueued'
    end

    def in_progress?
      status == 'in_progress'
    end

    def completed?
      status == 'completed'
    end

    def failed?
      status == 'failed'
    end

    def append_log_entry(type:, exhibit: nil, **args)
      events.create(type: type, exhibit: exhibit, data: args)
    rescue StandardError => e
      Rails.logger.error("Unable to create log entry for job tracker #{id}: #{e}")
    end

    def top_level_job_tracker
      if on.is_a?(Spotlight::JobTracker)
        on.top_level_job_tracker
      else
        self
      end
    end

    private

    def number_with_delimiter(*args)
      ActiveSupport::NumberHelper.number_to_delimited(*args)
    end
  end
end
