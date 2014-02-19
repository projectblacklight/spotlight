FactoryGirl.define do
  factory :search, class: Spotlight::Search do
    exhibit Spotlight::Exhibit.default
    title "Search1"
    featured_image 'https://stacks.stanford.edu/image/dq287tq6352/dq287tq6352_05_0001_thumb'
  end

  factory :published_search, class: Spotlight::Search do
    exhibit Spotlight::Exhibit.default
    title "Search1"
    on_landing_page true
  end
end
  


