# frozen_string_literal: true

module Spotlight
  # :nodoc:
  class BulkUpdate < ActiveRecord::Base
    mount_uploader :file, Spotlight::BulkUpdatesUploader
    belongs_to :exhibit
  end
end
