# frozen_string_literal: true

module Spotlight
  ##
  # Page, browse category, and exhibit featured image thumbnails
  class FeaturedImageUploader < CarrierWave::Uploader::Base
    storage Spotlight::Engine.config.uploader_storage

    before :cache, :check_image_contents!

    def extension_allowlist
      Spotlight::Engine.config.allowed_upload_extensions
    end

    def content_type_allowlist
      [%r{image/}]
    end

    def store_dir
      "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end

    private

    # CarrierWave falls back to the declared content type (or the file extension) when it
    # can't identify the file from its contents, so a corrupt file named e.g. "photo.jpg"
    # passes the content_type_allowlist. Require that the file's bytes look like an image.
    def check_image_contents!(new_file)
      content_type = detected_content_type(new_file)
      return if allowlisted_content_type?(content_type_allowlist, content_type)

      raise CarrierWave::IntegrityError, I18n.t(:'errors.messages.content_type_allowlist_error',
                                                content_type:, allowed_types: content_type_allowlist.join(', '))
    end

    def detected_content_type(new_file)
      io = new_file.to_file || StringIO.new(new_file.read.to_s)
      Marcel::Magic.by_magic(io)&.type || Marcel::MimeType::BINARY
    ensure
      io.close if io.is_a?(File)
    end
  end
end
