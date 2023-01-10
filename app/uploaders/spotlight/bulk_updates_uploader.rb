# frozen_string_literal: true

module Spotlight
  # :nodoc:
  class BulkUpdatesUploader < CarrierWave::Uploader::Base
    storage Spotlight::Engine.config.uploader_storage
  end
end
