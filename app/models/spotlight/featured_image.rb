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

    def remote_image_url=(url)
      # if the image is local, this step will fail..
      # hopefully it's local because it's an uploaded resource, and we'll
      # catch is in before_validation..
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
