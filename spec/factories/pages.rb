FactoryGirl.define do
  factory :feature_page, class: Spotlight::FeaturePage do
    exhibit Spotlight::Exhibit.default
    title "Page1"
    published  true
  end
  factory :about_page, class: Spotlight::AboutPage do
    exhibit Spotlight::Exhibit.default
    title "Page1"
    published  true
  end

  factory :home_page, class: Spotlight::HomePage do
    exhibit Spotlight::Exhibit.default
    title "Page1"
    published  true
  end
end
  

