FactoryBot.define do
  factory :tag, class: ActsAsTaggableOn::Tag do
    sequence(:name) { |n| "tag#{n}" }
  end

  factory :tagging, class: ActsAsTaggableOn::Tagging do
    sequence(:tag) { |n| FactoryBot.create(:tag, name: "tagging#{n}") }
    tagger { FactoryBot.create(:exhibit) }
    taggable { FactoryBot.create(:exhibit) }
    context :tags
  end
end
