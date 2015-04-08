FactoryGirl.define do
  factory :search, class: Spotlight::Search do
    exhibit
    title 'Search1'
  end

  factory :published_search, class: Spotlight::Search do
    exhibit
    title 'Search1'
    on_landing_page true
  end

  factory :default_search, class: Spotlight::Search do
    title 'All Exhibit Items'
    long_description 'All items in this exhibit.'

    after(:build) { |search| search.thumbnail = FactoryGirl.create(:featured_image) }
  end

  factory :featured_image, class: Spotlight::FeaturedImage do
    image { File.open(File.join(FIXTURES_PATH, 'avatar.png')) }
  end
end
