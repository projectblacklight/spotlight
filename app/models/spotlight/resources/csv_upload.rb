module Spotlight
  class Resources::CsvUpload
    attr_reader :url
    include ActiveModel::Model
    extend ActiveModel::Translation
  end
end
