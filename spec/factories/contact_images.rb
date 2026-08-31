# frozen_string_literal: true

FactoryBot.define do
  factory :contact_image, class: 'Spotlight::ContactImage' do
    image { Rack::Test::UploadedFile.new(File.expand_path(File.join('..', 'fixtures', 'avatar.png'), __dir__)) }
    iiif_tilesource { 'http://127.0.0.1:9999/images/78' }
  end
end
