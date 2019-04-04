# frozen_string_literal: true

module Spotlight
  module Resources
    # Raw solr document uploads
    class JsonUpload < Spotlight::Resource
      store :data, accessors: :json
    end
  end
end
