FactoryGirl.define do
  factory :resource, class: Spotlight::Resource do
    exhibit
    type 'Spotlight::Resource'
    url 'some url'
  end
  factory :uploaded_resource, class: Spotlight::Resources::Upload, parent: :resource do
    type 'Spotlight::Resources::Upload'
    url { Rack::Test::UploadedFile.new(File.expand_path(File.join('..', 'fixtures', 'avatar.png'), __dir__)) }
  end
end
