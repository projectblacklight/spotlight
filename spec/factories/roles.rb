FactoryGirl.define do
  factory :role, class: Spotlight::Role do
    exhibit
    role 'curator'
    user
  end
end
