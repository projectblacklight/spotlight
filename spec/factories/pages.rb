FactoryGirl.define do
  factory :feature_page, class: Spotlight::FeaturePage do
    exhibit Spotlight::ExhibitFactory.default
    title "Page1"
    published  true
  end
  factory :feature_subpage, parent: :feature_page do
    association :parent_page, factory: :feature_page
  end
  factory :about_page, class: Spotlight::AboutPage do
    exhibit Spotlight::ExhibitFactory.default
    title "Page1"
    published  true
  end

  factory :home_page, class: Spotlight::HomePage do
    exhibit Spotlight::ExhibitFactory.default
    title "Page1"
  end
end
  

