FactoryGirl.define do
  factory :tag, class: ActsAsTaggableOn::Tag do
    sequence(:name) { |n| "tag#{n}" }
  end

  factory :tagging, class: ActsAsTaggableOn::Tagging do
    sequence(:tag) { |n| FactoryGirl.create(:tag, name: "tagging#{n}") }
    tagger Spotlight::ExhibitFactory.default
    context :tags
  end
end
  


