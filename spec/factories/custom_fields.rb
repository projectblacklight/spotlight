FactoryBot.define do
  factory :custom_field, class: Spotlight::CustomField do
    exhibit
    field 'field_name'
    configuration('label' => 'Some Field')
  end
end
