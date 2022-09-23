# frozen_string_literal: true

module Spotlight::RiiifService
  # @param [Spotlight::FeaturedImage] image
  def self.thumbnail_path(image)
    Riiif::Engine.routes.url_helpers.image_path(image, size: '!400,400')
  end

  # @param [Spotlight::Exhibit] exhibit
  # @param [Spotlight::FeaturedImage] image
  def self.manifest_path(exhibit, image)
    Spotlight::Engine.routes.url_helpers.manifest_exhibit_solr_document_path(exhibit, "#{exhibit.id}-#{image.id}")
  end

  def self.info(id)
    Riiif::Image.new(id).info
  end
end
