FactoryBot.define do
  factory :main_navigation, class: Spotlight::MainNavigation do
    exhibit
    nav_type 'browse'
    display true
  end
end
