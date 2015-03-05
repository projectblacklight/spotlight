module Spotlight
  class SetDefaultThumbnailJob < ActiveJob::Base
    queue_as :default

    def perform(resource)
      
      first_item = images.first

      if first_item
        self.thumbnail = self.create_thumbnail remote_image_url: first_item.last
      end
    end
  end
end
