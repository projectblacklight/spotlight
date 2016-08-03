module Spotlight
  # Used by RIIIF to find files uploaded by carrierwave
  class CarrierwaveFileResolver < Riiif::AbstractFileSystemResolver
    def pattern(id)
      # TODO: need to make Resource::Upload be a kind of FeaturedImage.
      uploaded_file = Spotlight::FeaturedImage.find(id).image.file
      raise Riiif::ImageNotFoundError, "unable to find file for #{id}" if uploaded_file.nil?
      uploaded_file.file
    end
  end
end
