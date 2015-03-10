# encoding: utf-8

class Spotlight::FeaturedImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage Spotlight::Engine.config.uploader_storage
  
  version :cropped do
    process crop: :image  ## Crops this version based on original image
  end

  version :thumb, from_version: :cropped do
    process resize_to_fill: [400, 300]
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

end
