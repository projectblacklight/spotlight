FactoryBot.define do
  factory :unstarted_reindexing_log_entry, class: Spotlight::ReindexingLogEntry do
    items_reindexed_count { 15 }
    job_status { 'unstarted' }
    exhibit
    user
  end

  factory :reindexing_log_entry, class: Spotlight::ReindexingLogEntry do
    items_reindexed_count { 10 }
    start_time { Time.zone.parse('2017-01-05 23:00:00') }
    end_time { Time.zone.parse('2017-01-05 23:05:00') }
    job_status { 'succeeded' }
    exhibit
    user
  end

  factory :reindexing_log_entry_no_user, class: Spotlight::ReindexingLogEntry do
    items_reindexed_count { 10 }
    start_time { Time.zone.parse('2017-01-05 23:00:00') }
    end_time { Time.zone.parse('2017-01-05 23:05:00') }
    job_status { 'succeeded' }
    exhibit
  end

  factory :in_progress_reindexing_log_entry, class: Spotlight::ReindexingLogEntry do
    items_reindexed_count { 100 }
    start_time { Time.zone.now - 300 }
    end_time { nil }
    job_status { 'in_progress' }
    exhibit
    user
  end

  factory :recent_reindexing_log_entry, class: Spotlight::ReindexingLogEntry do
    sequence(:items_reindexed_count)
    start_time { Time.zone.now - 86_400 }
    end_time { Time.zone.now - 86_100 }
    job_status { 'succeeded' }
    exhibit
    user
  end

  factory :failed_reindexing_log_entry, class: Spotlight::ReindexingLogEntry do
    items_reindexed_count { 10 }
    start_time { Time.zone.parse('2017-01-10 23:00:00') }
    end_time { Time.zone.parse('2017-01-10 23:05:00') }
    job_status { 'failed' }
    exhibit
    user
  end
end
