FactoryBot.define do
  factory :exhibit, class: Spotlight::Exhibit do
    sequence(:title) { |n| "Exhibit Title #{n}" }
    published true
    after(:build) { |exhibit| exhibit.searches << FactoryBot.build(:default_search, exhibit: exhibit) }

    trait :with_thumbnail do
      association :thumbnail, factory: :exhibit_thumbnail
    end
  end
end
