module Spotlight
  ##
  # Exhibit contact profile pictures
  class AvatarUploader < CarrierWave::Uploader::Base
    include CarrierWave::MiniMagick

    storage Spotlight::Engine.config.uploader_storage

    version :thumb do
      process crop: :avatar ## Crops this version based on original image
      resize_to_limit(70, 70)
    end

    # Override the directory where uploaded files will be stored.
    # This is a sensible default for uploaders that are meant to be mounted:
    def store_dir
      "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end
  end
end
