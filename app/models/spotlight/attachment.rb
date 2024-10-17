# frozen_string_literal: true

module Spotlight
  ##
  # Sir-trevor image upload attachments
  class Attachment < ActiveRecord::Base
    belongs_to :exhibit
    mount_uploader :file, Spotlight::AttachmentUploader

    def as_json(options = nil)
      file.as_json(options).merge(name:, uid:, attachment: to_global_id)
    end
  end
end
