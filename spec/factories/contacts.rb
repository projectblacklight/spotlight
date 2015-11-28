FactoryGirl.define do
  factory :contact, class: Spotlight::Contact do
    exhibit
    avatar { Rack::Test::UploadedFile.new(File.expand_path(File.join('..', 'fixtures', 'avatar.png'), __dir__)) }
  end
end
