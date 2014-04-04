FactoryGirl.define do
  factory :search, class: Spotlight::Search do
    exhibit
    title "Search1"
    featured_item_id 'dq287tq6352'
  end

  factory :published_search, class: Spotlight::Search do
    exhibit
    title "Search1"
    on_landing_page true
  end
end
  


