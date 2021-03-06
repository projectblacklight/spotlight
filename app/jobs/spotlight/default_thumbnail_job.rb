# frozen_string_literal: true

module Spotlight
  ###
  # Calls the #set_default_thumbnail method
  # on the object passed in and calls save
  ###
  class DefaultThumbnailJob < Spotlight::ApplicationJob
    def perform(thumbnailable)
      thumbnailable.set_default_thumbnail
      thumbnailable.save
    end
  end
end
