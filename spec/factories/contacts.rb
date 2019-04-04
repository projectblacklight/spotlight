# frozen_string_literal: true

FactoryBot.define do
  factory :contact, class: Spotlight::Contact do
    exhibit

    trait :with_avatar do
      association :avatar, factory: :contact_image
    end
  end
end
