FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password "insecure"

    factory :user_with_exhibit do
      after(:create) do |user, evaluator|
        create_list(:role, 1, user: user, exhibit: Spotlight::Exhibit.default)
      end
    end
  end
end
  
