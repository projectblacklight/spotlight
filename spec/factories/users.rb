# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'insecure' }
    factory :site_admin do
      after(:create) do |user, _evaluator|
        user.roles.create role: 'admin', resource: Spotlight::Site.instance
      end
    end

    factory :named_exhibit_roles do
      transient do
        exhibit { FactoryBot.create(:exhibit) }
        role { nil }
      end

      after(:create) do |user, evaluator|
        user.roles.create role: evaluator.role, resource: evaluator.exhibit if evaluator.role
      end

      factory :exhibit_admin do
        transient do
          role { 'admin' }
        end
      end

      factory :exhibit_curator do
        transient do
          role { 'curator' }
        end
      end
    end

    trait :with_exhibit_role do
      transient do
        exhibit { FactoryBot.create(:exhibit) }
        role { nil }
      end

      after(:create) do |user, evaluator|
        user.roles.create role: evaluator.role, resource: evaluator.exhibit if evaluator.role
      end
    end

    factory :exhibit_visitor do
    end
  end
end
