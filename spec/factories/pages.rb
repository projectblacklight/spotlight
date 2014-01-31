FactoryGirl.define do
  factory :page, class: Spotlight::Page do
    exhibit Spotlight::Exhibit.default
    title "Page1"
  end
end
  

