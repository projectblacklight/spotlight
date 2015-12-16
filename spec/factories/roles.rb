FactoryGirl.define do
  factory :role, class: Spotlight::Role do
    resource { FactoryGirl.build(:exhibit) }
    role 'curator'
    user
  end
end
