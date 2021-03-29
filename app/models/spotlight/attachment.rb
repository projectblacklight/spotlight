# frozen_string_literal: true

module Spotlight
  ##
  # Sir-trevor image upload attachments
  class Attachment < ActiveRecord::Base
    # Open to alternatives on how to do this, but this works
    include Rails.application.routes.url_helpers

    belongs_to :exhibit
    has_one_attached :file

    def as_json(_options = nil)
      # as_json has problems with single has_one_attached content
      # https://github.com/rails/rails/issues/33036
      {
        name: name, uid: uid, attachment: to_global_id, url: rails_blob_path(file, only_path: true)
      }
    end
  end
end
