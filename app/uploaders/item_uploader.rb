# encoding: utf-8

class ItemUploader < CarrierWave::Uploader::Base
  storage :file

  def extension_white_list
    model.exhibit.blacklight_config.allowed_upload_extensions
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

end
