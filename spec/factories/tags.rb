FactoryGirl.define do
  factory :tag, class: ActsAsTaggableOn::Tag do
    sequence(:name) { |n| "tag#{n}" }
  end
end
  


