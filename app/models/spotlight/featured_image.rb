module Spotlight
  class FeaturedImage < ActiveRecord::Base
    mount_uploader :image, Spotlight::FeaturedImageUploader

    before_validation do
      if self.document and self.document.uploaded_resource?
        self.image = self.document.uploaded_resource.url.file
      end
    end

    after_save do
      if image.present?
        image.cache! if !image.cached?
        image.store!
        recreate_image_versions
      end
    end

    def remote_image_url= url
      # if the image is local, this step will fail.. 
      # hopefully it's local because it's an uploaded resource, and we'll
      # catch is in before_validation..
      unless url.starts_with? "/"
        super url
      end
    end

    def document
      return unless document_global_id && source == 'exhibit'

      if @document and document_global_id != @document.to_global_id.to_s
        @document = nil
      end

      @document ||= GlobalID::Locator.locate document_global_id
    end
  end
end