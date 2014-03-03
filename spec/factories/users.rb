FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password "insecure"

    factory :site_admin do
      after(:create) do |user, evaluator|
        create_list(:role, 1, user: user, exhibit_id: nil, role: 'admin')
      end
    end

    factory :exhibit_admin do
      after(:create) do |user, evaluator|
        create_list(:role, 1, user: user, exhibit: Spotlight::Exhibit.default, role: 'admin')
      end
    end
    factory :exhibit_curator do
      after(:create) do |user, evaluator|
        create_list(:role, 1, user: user, exhibit: Spotlight::Exhibit.default, role: 'curator')
      end
    end

    factory :exhibit_visitor do
      
    end
  end
end
  
