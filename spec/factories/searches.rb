# frozen_string_literal: true

FactoryBot.define do
  factory :search, class: 'Spotlight::Search' do
    exhibit
    sequence(:title) { |n| "Exhibit Search #{n}" }
    sequence(:slug) { |n| "Search#{n}" }

    after(:build) { |search| search.thumbnail = FactoryBot.create(:featured_image) }

    factory :search_with_groups do
      transient do
        groups_count { 2 }
      end
    end

    after(:create) do |search, evaluator|
      create_list(:group, evaluator.groups_count, searches: [search]) if evaluator.respond_to?(:groups_count)
    end
  end

  factory :published_search, parent: :search do
    published { true }
  end

  factory :default_search, class: 'Spotlight::Search' do
    exhibit
    title { 'All exhibit items' }
    long_description { 'All items in this exhibit.' }

    after(:build) { |search| search.thumbnail = FactoryBot.create(:featured_image) }
  end

  factory :search_field_search, class: 'Spotlight::Search' do
    exhibit
    title { 'Based on a search field' }
    query_params { { 'search_field' => 'search', 'q' => 'model' } }
  end

  factory :facet_search, class: 'Spotlight::Search' do
    exhibit
    title { 'Based on a facet' }
    query_params { { 'f' => { 'language_ssim' => 'Latin' } } }
  end
end
