FactoryGirl.define do
  factory :contact, class: Spotlight::Contact do
    exhibit

    trait :with_avatar do
      association :avatar, factory: :featured_image
    end
  end
end
