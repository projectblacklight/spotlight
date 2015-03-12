module Spotlight
  class FeaturedImage < ActiveRecord::Base
    mount_uploader :image, Spotlight::FeaturedImageUploader
    
    after_save do
      if image.present?
        image.cache! if !image.cached?
        image.store!
        recreate_image_versions
      end
    end
    
    def document
      return unless document_global_id && source == 'exhibit'
      @document ||= GlobalID::Locator.locate document_global_id
    end
  end
end