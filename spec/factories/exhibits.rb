FactoryGirl.define do
  factory :exhibit, class: Spotlight::Exhibit do
    sequence(:title) { |n| "Exhibit Title #{n}" }
    before(:create) { |exhibit| Spotlight::ExhibitFactory.create(exhibit) }
  end
end
  

