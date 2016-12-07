module Spotlight
  ##
  # Page, browse category, and exhibit featured image thumbnails
  class FeaturedImageUploader < CarrierWave::Uploader::Base
    include CarrierWave::MiniMagick

    storage Spotlight::Engine.config.uploader_storage

    # version :thumb, from_version: :cropped do
    #   process resize_to_fill: Spotlight::Engine.config.featured_image_thumb_size
    # end

    # version :square, from_version: :cropped do
    #   process resize_to_fill: Spotlight::Engine.config.featured_image_square_size
    # end

    def store_dir
      "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end

    def default_url
      ActionController::Base.helpers.image_path('spotlight/fallback/' + [version_name, 'default.png'].compact.join('_'))
    end
  end
end
