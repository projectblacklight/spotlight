# frozen_string_literal: true

module Spotlight
  # HTML <meta> tag helpers
  module JobTrackersHelper
    def job_status_icon(job_tracker)
      content_tag :span, title: t(job_tracker.status || 'missing', scope: 'spotlight.job_trackers.status') do
        if job_tracker.enqueued? || job_tracker.in_progress?
          '⏱'
        elsif job_tracker.completed?
          '✅'
        elsif job_tracker.failed?
          '🟥'
        else
          ''
        end
      end
    end

    def job_tracker_event_table_row_class(event)
      case event.type
      when 'error'
        'table-danger'
      when 'info', 'summary'
        ''
      else
        "table-#{event.type}"
      end
    end
  end
end
