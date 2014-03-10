FactoryGirl.define do
  factory :feature_page, class: Spotlight::FeaturePage do
    exhibit
    title "Page1"
    published  true
  end
  factory :feature_subpage, parent: :feature_page do
    ignore do
      exhibit
    end
    title "SubPage1"
    after(:build) { |subpage, evaluator| subpage.parent_page = FactoryGirl.create(:feature_page, exhibit: evaluator.exhibit) }
  end
  factory :about_page, class: Spotlight::AboutPage do
    exhibit
    title "Page1"
    published  true
  end

  factory :home_page, class: Spotlight::HomePage do
    exhibit
    title "Page1"
  end
end
  

