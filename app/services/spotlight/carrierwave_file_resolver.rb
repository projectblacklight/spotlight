# frozen_string_literal: true

module Spotlight
  # Used by RIIIF to find files uploaded by carrierwave
  class CarrierwaveFileResolver < Riiif::AbstractFileSystemResolver
    # Override initialzer to avoid deprecation about not providing base path
    def initialize
      # nop
    end

    def pattern(id)
      uploaded_file = Spotlight::FeaturedImage.find(id).image.blob
      raise Riiif::ImageNotFoundError, "unable to find file for #{id}" if uploaded_file.nil?

      ActiveStorage::Blob.service.path_for(uploaded_file.key)
    end
  end
end
