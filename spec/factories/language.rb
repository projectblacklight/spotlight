# frozen_string_literal: true

FactoryBot.define do
  factory :language, class: Spotlight::Language do
    exhibit
    locale { 'es' }
  end
end
