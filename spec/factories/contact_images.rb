FactoryBot.define do
  factory :contact_image, class: Spotlight::ContactImage do
    image { Rack::Test::UploadedFile.new(File.expand_path(File.join('..', 'fixtures', 'avatar.png'), __dir__)) }
    iiif_tilesource { 'https://exhibits-stage.stanford.edu/images/78' }
  end
end
