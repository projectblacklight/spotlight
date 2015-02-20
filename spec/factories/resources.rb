FactoryGirl.define do
  factory :resource, class: Spotlight::Resource do
    exhibit
    type "Spotlight::Resource"
    url "some url"
  end
  factory :uploaded_resource, class: Spotlight::Resources::Upload, parent: :resource do
    type "Spotlight::Resources::Upload"
    url { Rack::Test::UploadedFile.new(File.join(FIXTURES_PATH, "avatar.png")) }
  end
end
