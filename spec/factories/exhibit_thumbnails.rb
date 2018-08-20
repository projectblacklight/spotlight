FactoryBot.define do
  factory :exhibit_thumbnail, class: Spotlight::ExhibitThumbnail do
    image { Rack::Test::UploadedFile.new(File.expand_path(File.join('..', 'fixtures', 'avatar.png'), __dir__)) }
    iiif_tilesource { 'https://exhibits-stage.stanford.edu/images/78' }
  end
end
