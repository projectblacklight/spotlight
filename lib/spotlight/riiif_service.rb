# frozen_string_literal: true

module Spotlight
  # iiif_service module for when using the built-in riiif server
  module RiiifService
    # @param [Spotlight::FeaturedImage] image
    # @return [String]
    def self.thumbnail_url(image)
      Riiif::Engine.routes.url_helpers.image_path(image, size: '!400,400')
    end

    # @param [Spotlight::FeaturedImage] image
    # @return [String]
    def self.info_url(image)
      Riiif::Engine.routes.url_helpers.info_url(image)
    end

    # @param [Spotlight::Exhibit] exhibit
    # @param [Spotlight::FeaturedImage] image
    # @return [String]
    def self.manifest_url(exhibit, image)
      Spotlight::Engine.routes.url_helpers.manifest_exhibit_solr_document_path(exhibit, "#{exhibit.id}-#{image.id}")
    end

    # @param [String] id
    # @return [Hash]
    def self.info(id)
      Riiif::Image.new(id).info
    end
  end
end
