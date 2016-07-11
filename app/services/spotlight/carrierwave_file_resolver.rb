module Spotlight
  # Used by RIIIF to find files uploaded by carrierwave
  class CarrierwaveFileResolver < Riiif::AbstractFileSystemResolver
    def pattern(id)
      Spotlight::FeaturedImage.find(id).image.file.file
    end
  end
end
