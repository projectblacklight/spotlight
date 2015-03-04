module Spotlight
  class FeaturedImage < ActiveRecord::Base
    belongs_to :parent, polymorphic: true, touch: true

    mount_uploader :image, Spotlight::FeaturedImageUploader
    
    after_save do
      recreate_image_versions if image.present?
    end
    
    def document
      return unless document_global_id && source == 'exhibit'
      @document ||= GlobalID::Locator.locate document_global_id
    end
  end
end