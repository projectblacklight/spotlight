FactoryGirl.define do
  factory :feature_page, class: Spotlight::FeaturePage do
    exhibit Spotlight::Exhibit.default
    title "Page1"
  end
  factory :about_page, class: Spotlight::AboutPage do
    exhibit Spotlight::Exhibit.default
    title "Page1"
  end
end
  

