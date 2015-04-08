module Spotlight
  module Resources
    ##
    # Shim object for CSV Uploads. see {Spotlight::AddUploadsFromCsv}
    class CsvUpload
      attr_reader :url
      include ActiveModel::Model
      extend ActiveModel::Translation
    end
  end
end
