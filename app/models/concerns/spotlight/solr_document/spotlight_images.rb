###
 # Simple concern mixed into SolrDocument to create
 # a mapping of configured Spotlight::ImageDerivatives
 # to their configured fields in the SolrDocument.
 # Any derivatives configured (descibed in Spotlight::ImageDerivatives)
 # will be available under #spotlight_image_versions and an array of available versions
 # (regardless of their is related data in the document) in the #spotlight_image_versions#versions array.
###
module Spotlight::SolrDocument::SpotlightImages

  def spotlight_image_versions
    @spotlight_image_versions ||= Versions.new(self)
  end

  class Versions
    include Spotlight::ImageDerivatives
    attr_reader :versions

    def initialize(document)
      @versions = spotlight_image_derivatives.map do |derivative|
        version = version_name(derivative)
        self.class.send(:define_method, version) do
          document[derivative[:field]]
        end
        version
      end
    end

    private

    def version_name(derivative)
      derivative[:version] || default_version_name
    end

    def default_version_name
      :full
    end
  end

end
