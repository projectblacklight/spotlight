FactoryGirl.define do
  factory :feature_page, class: Spotlight::FeaturePage do
    exhibit
    title "Page1"
    published  true
    content "[]"
  end
  factory :feature_subpage, parent: :feature_page do
    transient do
      exhibit
    end
    title "SubPage1"
    content "[]"
    after(:build) { |subpage, evaluator| subpage.parent_page = FactoryGirl.create(:feature_page, exhibit: evaluator.exhibit) }
  end
  factory :about_page, class: Spotlight::AboutPage do
    exhibit
    title "Page1"
    content "[]"
    published  true
  end

  factory :home_page, class: Spotlight::HomePage do
    exhibit
    title "Page1"
  end
end
  

