FactoryGirl.define do
  factory :role, class: Spotlight::Role do
    exhibit
    role 'curate'
    user
  end
end
