# encoding: utf-8
module Spotlight
  ##
  # Exhibit and browse category custom mastheads
  class MastheadUploader < CarrierWave::Uploader::Base
    storage Spotlight::Engine.config.uploader_storage

    def store_dir
      "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end

    def default_url
      ActionController::Base.helpers.image_path('spotlight/fallback/' + [version_name, 'default.png'].compact.join('_'))
    end
  end
end
