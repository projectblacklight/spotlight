# frozen_string_literal: true

module Spotlight
  # :nodoc:
  class BulkUpdatesUploader < CarrierWave::Uploader::Base
    storage Spotlight::Engine.config.spotlight.uploader_storage
  end
end
