module Spotlight
  ##
  # Exhibit and browse category mastheads
  class Masthead < Spotlight::FeaturedImage
    def display?
      display && iiif_url.present?
    end

    # Duplicated from Spotlight::FeaturedImage, because mount_uploader
    # will overwrite it..
    #
    # if the image is local, this step will fail..
    # hopefully it's local because it's an uploaded resource, and we'll
    # catch is in before_validation..
    def remote_image_url=(url)
      super url unless url.starts_with? '/'
    end

    private

    def image_size
      [1800, 180]
    end
  end
end
