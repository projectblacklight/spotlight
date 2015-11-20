module Spotlight
  ###
  #  Simple concern to mixin to classes that
  #  fetches a default thumbnail after creation
  #  Classes that mixin this module should implement
  #  a set_default_thumbnail method themselves
  ###
  module DefaultThumbnailable
    extend ActiveSupport::Concern

    included do
      after_create(:fetch_default_thumb_later) if respond_to?(:after_create)
    end

    private

    def fetch_default_thumb_later
      DefaultThumbnailJob.perform_later(self)
    end

    def set_default_thumbnail
      fail NotImplementedError
    end
  end
end
