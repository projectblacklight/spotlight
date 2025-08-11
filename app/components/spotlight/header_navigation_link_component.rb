# frozen_string_literal: true

module Spotlight
  # This draws a navigation link in the header.
  # A downstream application may switch out the implementation to use different styles, etc.
  class HeaderNavigationLinkComponent < ViewComponent::Base
    def initialize(path:, active:, label:)
      @path = path
      @active = active
      @label = label
      super()
    end
  end
end
