FactoryGirl.define do
  factory :search, class: Spotlight::Search do
    exhibit Spotlight::Exhibit.default
    title "Search1"
  end
end
  


