# encoding: utf-8

class Spotlight::FeaturedImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file
  
  version :cropped do
    process crop: :image  ## Crops this version based on original image
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

end
