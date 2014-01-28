FactoryGirl.define do
  factory :exhibit, class: Spotlight::Exhibit do
    sequence(:name) { |n| "exhibit#{n}" }
  end
end
  

