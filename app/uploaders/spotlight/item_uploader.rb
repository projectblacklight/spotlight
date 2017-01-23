# encoding: utf-8
module Spotlight
  ##
  # Uploaded resource image attachments, downloaded locally for cropping and
  # representation. See {Spotlight::Resource::Upload}
  class ItemUploader < CarrierWave::Uploader::Base
    include CarrierWave::MiniMagick

    storage Spotlight::Engine.config.uploader_storage

    def extension_white_list
      Spotlight::Engine.config.allowed_upload_extensions
    end

    def store_dir
      "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end
  end
end
