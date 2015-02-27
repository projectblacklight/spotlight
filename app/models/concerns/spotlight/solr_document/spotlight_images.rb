module Spotlight::SolrDocument::SpotlightImages

  def spotlight_image_versions
    @spotlight_image_versions ||= Versions.new(self)
  end

  class Versions
    include Spotlight::ImageDerivatives
    attr_reader :versions

    def initialize(document)
      @versions = []
      @@spotlight_image_derivatives.each do |derivative|
        version = version_name(derivative)
        self.class.send(:define_method, version) do
          document[derivative[:field]]
        end
        @versions << version
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
