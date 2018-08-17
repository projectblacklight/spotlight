FactoryBot.define do
  factory :featured_image, class: Spotlight::FeaturedImage do
    image { Rack::Test::UploadedFile.new(File.expand_path(File.join('..', 'fixtures', 'avatar.png'), __dir__)) }
    iiif_tilesource { 'https://exhibits-stage.stanford.edu/images/78' }
  end

  factory :masthead, class: Spotlight::Masthead do
    image { Rack::Test::UploadedFile.new(File.expand_path(File.join('..', 'fixtures', 'avatar.png'), __dir__)) }
  end
end
