# frozen_string_literal: true

FactoryBot.define do
  factory :group, class: 'Spotlight::Group' do
    exhibit

    factory :group_with_searches do
      transient do
        searches_count { 5 }
      end
    end

    after(:create) do |group, evaluator|
      create_list(:search, evaluator.searches_count, groups: [group]) if evaluator.respond_to?(:searches_count)
    end
  end
end
