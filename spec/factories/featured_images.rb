FactoryGirl.define do
  factory :featured_image, class: Spotlight::FeaturedImage do
    image { Rack::Test::UploadedFile.new(File.join(FIXTURES_PATH, 'avatar.png')) }
  end

  factory :masthead, class: Spotlight::Masthead do
    image { Rack::Test::UploadedFile.new(File.join(FIXTURES_PATH, 'avatar.png')) }
  end
end
