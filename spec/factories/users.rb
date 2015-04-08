FactoryGirl.define do
  factory :user do
    transient do
      exhibit { FactoryGirl.create(:exhibit) }
    end
    sequence(:email) { |n| "user#{n}@example.com" }
    password 'insecure'

    factory :site_admin do
      after(:create) do |user, _evaluator|
        create_list(:role, 1, user: user, exhibit_id: nil, role: 'admin')
      end
    end

    factory :exhibit_admin do
      after(:create) do |user, evaluator|
        create_list(:role, 1, user: user, exhibit: evaluator.exhibit, role: 'admin')
      end
    end
    factory :exhibit_curator do
      after(:create) do |user, evaluator|
        create_list(:role, 1, user: user, exhibit: evaluator.exhibit, role: 'curator')
      end
    end

    factory :exhibit_visitor do
    end
  end
end
