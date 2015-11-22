module Spotlight
  ###
  # Calls the #set_default_thumbnail method
  # on the object passed in and calls save
  ###
  class DefaultThumbnailJob < ActiveJob::Base
    queue_as :default

    def perform(thumbnailable)
      thumbnailable.set_default_thumbnail
      thumbnailable.save
    end
  end
end
