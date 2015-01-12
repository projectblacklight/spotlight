module Spotlight
  class AvatarUploader < CarrierWave::Uploader::Base
    include CarrierWave::MiniMagick

    storage :file

    version :thumb do
      process crop: :avatar  ## Crops this version based on original image
      resize_to_limit(70,70)
    end
  end
end
