# frozen_string_literal: true

FactoryBot.define do
  factory :job_tracker, class: 'Spotlight::JobTracker' do
    user
    on factory: :exhibit
    resource factory: :exhibit
    created_at { Time.zone.parse('2017-01-05 23:00:00') }
    updated_at { Time.zone.parse('2017-01-05 23:05:00') }
  end
end
