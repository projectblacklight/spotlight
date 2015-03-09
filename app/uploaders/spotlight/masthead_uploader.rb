# encoding: utf-8
module Spotlight
  class MastheadUploader < CarrierWave::Uploader::Base
    include CarrierWave::MiniMagick
    storage Spotlight::Engine.config.uploader_storage

    version :cropped do
      process crop: :image  ## Crops this version based on original image
      process resize_to_fill: [1800, 120]
    end

    def store_dir
      "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end
  end
end
