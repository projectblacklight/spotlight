module Spotlight
  ##
  # Featured images for browse categories, feature pages, and exhibits
  class FeaturedImage < ActiveRecord::Base
    mount_uploader :image, Spotlight::FeaturedImageUploader

    before_validation :set_image_from_uploaded_resource

    after_save do
      if image.present?
        image.cache! unless image.cached?
        image.store!
        recreate_image_versions
      end
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

    private

    def set_image_from_uploaded_resource
      return unless document && document.uploaded_resource?
      self.image = document.uploaded_resource.url.file
    end
  end
end
