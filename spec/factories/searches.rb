FactoryGirl.define do
  factory :search, class: Spotlight::Search do
    exhibit Spotlight::Exhibit.default
    title "Search1"
  end

  factory :published_search, class: Spotlight::Search do
    exhibit Spotlight::Exhibit.default
    title "Search1"
    on_landing_page true
  end
end
  


