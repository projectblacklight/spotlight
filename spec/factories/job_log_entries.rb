FactoryBot.define do
  factory :unstarted_job_log_entry, class: Spotlight::JobLogEntry do
    job_item_count 15
    job_status 'unstarted'
    job_type 'some job type'
    exhibit
    user
  end

  factory :job_log_entry, class: Spotlight::JobLogEntry do
    job_item_count 10
    start_time { Time.zone.parse('2017-01-05 23:00:00') }
    end_time { Time.zone.parse('2017-01-05 23:05:00') }
    job_status 'succeeded'
    exhibit
    user
  end

  factory :job_log_entry_no_user, class: Spotlight::JobLogEntry do
    job_item_count 10
    start_time { Time.zone.parse('2017-01-05 23:00:00') }
    end_time { Time.zone.parse('2017-01-05 23:05:00') }
    job_status 'succeeded'
    job_type 'some job type'
    exhibit
  end

  factory :in_progress_job_log_entry, class: Spotlight::JobLogEntry do
    job_item_count 100
    start_time { Time.zone.now - 300 }
    end_time nil
    job_status 'in_progress'
    job_type 'some job type'
    exhibit
    user
  end

  factory :recent_job_log_entry, class: Spotlight::JobLogEntry do
    sequence(:job_item_count)
    start_time { Time.zone.now - 86_400 }
    end_time { Time.zone.now - 86_100 }
    job_status 'succeeded'
    job_type 'some job type'
    exhibit
    user
  end

  factory :failed_job_log_entry, class: Spotlight::JobLogEntry do
    job_item_count 10
    start_time { Time.zone.parse('2017-01-10 23:00:00') }
    end_time { Time.zone.parse('2017-01-10 23:05:00') }
    job_status 'failed'
    job_type 'some job type'
    exhibit
    user
  end

  factory :in_progress_alternative_log_entry, class: Spotlight::JobLogEntry do
    job_item_count 1000
    start_time { Time.zone.now - 300 }
    end_time nil
    job_status 'in_progress'
    job_type 'alternative'
    exhibit
    user
  end
end
