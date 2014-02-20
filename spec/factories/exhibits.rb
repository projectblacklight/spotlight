FactoryGirl.define do
  factory :exhibit, class: Spotlight::Exhibit do
    sequence(:name) { |n| "exhibit#{n}" }
    sequence(:title) { |n| "Exhibit Title #{n}" }
  end
end
  

