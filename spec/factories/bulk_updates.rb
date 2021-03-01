# frozen_string_literal: true

FactoryBot.define do
  factory :bulk_update, class: 'Spotlight::BulkUpdate' do
    file { Rack::Test::UploadedFile.new(File.expand_path(File.join('..', 'fixtures', 'files', 'updated-bulk-update-template.csv'), __dir__)) }

    exhibit
  end

  factory :tagged_bulk_update, class: 'Spotlight::BulkUpdate' do
    file { Rack::Test::UploadedFile.new(File.expand_path(File.join('..', 'fixtures', 'files', 'updated-bulk-update-template-w-tags.csv'), __dir__)) }

    exhibit
  end
end
