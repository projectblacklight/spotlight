# frozen_string_literal: true

FactoryBot.define do
  factory :custom_search_field, class: 'Spotlight::CustomSearchField' do
    exhibit
    field { 'field_name_tesim^60' }
    configuration { { 'label' => 'Some Field' } }
  end
end
