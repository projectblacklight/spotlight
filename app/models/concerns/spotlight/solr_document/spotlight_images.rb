###
# Simple concern mixed into SolrDocument to create
# a mapping of configured Spotlight::ImageDerivatives
# to their configured fields in the SolrDocument.
# Any derivatives configured (descibed in Spotlight::ImageDerivatives)
# will be available under #spotlight_image_versions and an array of available versions
# (regardless of their is related data in the document) in the #spotlight_image_versions#versions array.
###
module Spotlight
  module SolrDocument
    ##
    # Spotlight image derivatives helpers
    module SpotlightImages
      def spotlight_image_versions
        @spotlight_image_versions ||= Versions.new(self)
      end

      ##
      # Spotlight image derivivative class
      class Versions
        include Spotlight::ImageDerivatives
        attr_reader :versions, :document

        def initialize(document)
          @document = document
          @versions = spotlight_image_derivatives.map do |derivative|
            version = version_name(derivative)
            self.class.send(:define_method, version) do
              Array.wrap(document.fetch(derivative[:field], []))
            end
            version
          end
        end

        def image_versions(*args)
          send(args.first).each_with_index.map do |_img, i|
            args.each_with_object({}) do |version, hash|
              hash[version] = send(version)[i]
            end
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
  end
end
