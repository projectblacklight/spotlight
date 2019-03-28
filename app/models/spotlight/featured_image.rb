# frozen_string_literal: true

module Spotlight
  ##
  # Featured images for browse categories, feature pages, and exhibits
  class FeaturedImage < ActiveRecord::Base
    mount_uploader :image, Spotlight::FeaturedImageUploader

    before_validation do
      next unless upload_id.present? && source == 'remote'

      # copy the image from the temp upload
      temp_image = Spotlight::TemporaryImage.find(upload_id)
      self.image = CarrierWave::SanitizedFile.new tempfile: StringIO.new(temp_image.image.read),
                                                  filename: temp_image.image.filename || temp_image.image.identifier,
                                                  content_type: temp_image.image.content_type

      # Unset the incoming iiif_tilesource, which points at the temp image
      self.iiif_tilesource = nil
    end

    after_commit do
      # Clean up the temporary image
      Spotlight::TemporaryImage.find(upload_id).delete if upload_id.present?
    end

    after_save do
      if image.present?
        image.cache! unless image.cached?
        image.store!
      end
    end

    attr_accessor :upload_id

    def iiif_url
      return if iiif_service_base.blank?

      [iiif_service_base, iiif_region || 'full', image_size.join(','), '0', 'default.jpg'].join('/')
    end

    # This is used to fetch images given the URL field in the CSV uploads
    # If the image is local, this step will fail, which is okay since the only
    # consumer is CSV uploads and the URL is intended to be remote
    def remote_image_url=(url)
      super url unless url.starts_with? '/'
    end

    def document
      return unless document_global_id && source == 'exhibit'

      @document = nil if @document && document_global_id != @document.to_global_id.to_s

      @document ||= GlobalID::Locator.locate document_global_id
    rescue Blacklight::Exceptions::RecordNotFound => e
      Rails.logger.info("Exception fetching record by id: #{document_global_id}")
      Rails.logger.info(e)

      nil
    end

    def file_present?
      image.file.present?
    end

    def iiif_tilesource
      if self[:iiif_tilesource]
        self[:iiif_tilesource]
      elsif file_present?
        riiif = Riiif::Engine.routes.url_helpers
        riiif.info_path(id)
      end
    end

    private

    def image_size
      Spotlight::Engine.config.featured_image_thumb_size
    end

    def iiif_service_base
      iiif_tilesource&.sub('/info.json', '')
    end
  end
end
