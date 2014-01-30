FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password "insecure"

    factory :exhibit_admin do
      after(:create) do |user, evaluator|
        create_list(:role, 1, user: user, exhibit: Spotlight::Exhibit.default, role: 'admin')
      end
    end
    factory :exhibit_curator do
      after(:create) do |user, evaluator|
        create_list(:role, 1, user: user, exhibit: Spotlight::Exhibit.default, role: 'curate')
      end
    end
  end
end
  
