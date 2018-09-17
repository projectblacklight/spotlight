module Spotlight
  ##
  # Page, browse category, and exhibit featured image thumbnails
  class FeaturedImageUploader < CarrierWave::Uploader::Base
    storage Spotlight::Engine.config.uploader_storage

    def extension_whitelist
      Spotlight::Engine.config.allowed_upload_extensions
    end

    def store_dir
      "#{Spotlight::Engine.config.upload_dir}/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end
  end
end
