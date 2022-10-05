# frozen_string_literal: true

module Spotlight
  module RiiifService
    # @param [Spotlight::FeaturedImage] image
    # @return [String]
    def self.thumbnail_path(image)
      Riiif::Engine.routes.url_helpers.image_path(image, size: '!400,400')
    end

    # @param [Spotlight::FeaturedImage] image
    # @return [String]
    def self.info_url(image)
      Riiif::Engine.routes.url_helpers.info_url(image)
    end

    # @param [Spotlight::FeaturedImage] image
    # @return [String]
    def self.info_path(image)
      Riiif::Engine.routes.url_helpers.info_path(image)
    end

    # @param [Spotlight::Exhibit] exhibit
    # @param [Spotlight::FeaturedImage] image
    # @return [String]
    def self.manifest_path(exhibit, image)
      Spotlight::Engine.routes.url_helpers.manifest_exhibit_solr_document_path(exhibit, "#{exhibit.id}-#{image.id}")
    end

    # @param [String] id
    # @return [Hash]
    def self.info(id)
      Riiif::Image.new(id).info
    end
  end
end
