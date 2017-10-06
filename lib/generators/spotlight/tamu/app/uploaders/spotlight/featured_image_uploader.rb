module Spotlight
  ##
  # Page, browse category, and exhibit featured image thumbnails
  class FeaturedImageUploader < CarrierWave::Uploader::Base
    storage Spotlight::Engine.config.uploader_storage
    
    after :remove, :cleanup_store_dir

    def extension_white_list
      Spotlight::Engine.config.allowed_upload_extensions
    end

    def store_dir
      "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end
    
    private
    
    def cleanup_store_dir
      store_dir_path = Rails.public_path.join(store_dir)      
      FileUtils.remove_dir(store_dir_path) if File.directory?(store_dir_path)
    end
  end
end
