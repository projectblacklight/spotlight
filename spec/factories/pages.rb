FactoryGirl.define do
  factory :feature_page, class: 'Spotlight::FeaturePage' do
    exhibit
    sequence(:title) { |n| "FeaturePage#{n}" }
    published true
    content '[]'
  end
  factory :feature_subpage, parent: :feature_page do
    transient do
      exhibit
    end
    title 'SubPage1'
    content '[]'
    after(:build) { |subpage, evaluator| subpage.parent_page = FactoryGirl.create(:feature_page, exhibit: evaluator.exhibit) }
  end
  factory :about_page, class: 'Spotlight::AboutPage' do
    exhibit
    sequence(:title) { |n| "AboutPage#{n}" }
    content '[]'
    published true
  end

  factory :home_page, class: 'Spotlight::HomePage' do
    exhibit
  end
end
