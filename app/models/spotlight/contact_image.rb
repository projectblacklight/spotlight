# frozen_string_literal: true

module Spotlight
  ###
  # A simple sub class of FeaturedImage to set a small square size for contacts
  class ContactImage < FeaturedImage
    private

    def image_size
      Spotlight::Engine.config.contact_square_size
    end
  end
end
