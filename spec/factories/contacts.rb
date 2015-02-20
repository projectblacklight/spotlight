FactoryGirl.define do
  factory :contact, class: Spotlight::Contact do
    exhibit
    avatar { Rack::Test::UploadedFile.new(File.join(FIXTURES_PATH, "avatar.png")) }
  end
end
  

