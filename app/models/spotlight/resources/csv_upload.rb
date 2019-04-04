# frozen_string_literal: true

module Spotlight
  module Resources
    ##
    # Shim object for CSV Uploads. see {Spotlight::AddUploadsFromCSV}
    class CsvUpload
      attr_reader :url
      include ActiveModel::Model
      extend ActiveModel::Translation
    end
  end
end
