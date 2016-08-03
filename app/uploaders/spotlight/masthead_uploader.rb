# encoding: utf-8
module Spotlight
  ##
  # Exhibit and browse category custom mastheads
  class MastheadUploader < CarrierWave::Uploader::Base
    storage Spotlight::Engine.config.uploader_storage

    def store_dir
      "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end
  end
end
