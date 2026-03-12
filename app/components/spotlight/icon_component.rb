# frozen_string_literal: true

module Spotlight
  # Displays the document
  class IconComponent < Blacklight::Icons::IconComponent
    def initialize(*args, **kwargs)
      Spotlight.deprecator.warn(
        'Spotlight::IconComponent is deprecated and will be removed in a future version. Use Blacklight::Icons::IconComponent instead.'
      )
      super
    end
  end
end
