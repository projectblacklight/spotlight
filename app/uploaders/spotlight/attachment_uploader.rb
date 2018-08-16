# encoding: utf-8
module Spotlight
  ##
  # Sir-trevor image widget uploads
  class AttachmentUploader < CarrierWave::Uploader::Base
    storage Spotlight::Engine.config.uploader_storage

    # Override the directory where uploaded files will be stored.
    def store_dir
      "#{Spotlight::Engine.config.upload_dir}/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end
  end
end
