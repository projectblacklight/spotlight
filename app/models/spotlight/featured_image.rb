module Spotlight
  ##
  # Featured images for browse categories, feature pages, and exhibits
  class FeaturedImage < ActiveRecord::Base
    mount_uploader :image, Spotlight::FeaturedImageUploader

    after_save do
      if image.present?
        image.cache! unless image.cached?
        image.store!
      end
    end

    after_create :set_tilesource_from_uploaded_resource

    def iiif_url
      return unless iiif_service_base.present?

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

      if @document && document_global_id != @document.to_global_id.to_s
        @document = nil
      end

      @document ||= GlobalID::Locator.locate document_global_id

    rescue Blacklight::Exceptions::RecordNotFound => e
      Rails.logger.info("Exception fetching record by id: #{document_global_id}")
      Rails.logger.info(e)

      nil
    end

    def file_present?
      image.file.present?
    end

    private

    def set_tilesource_from_uploaded_resource
      return if iiif_tilesource

      riiif = Riiif::Engine.routes.url_helpers
      self.iiif_tilesource = riiif.info_path(id)
      save
    end

    def image_size
      Spotlight::Engine.config.featured_image_thumb_size
    end

    def iiif_service_base
      return unless iiif_tilesource

      iiif_tilesource.sub('/info.json', '')
    end
  end
end
