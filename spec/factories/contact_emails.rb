FactoryGirl.define do
  factory :contact_email, class: Spotlight::ContactEmail do
    email 'exhibit_contact@example.com'
    exhibit
  end
end
