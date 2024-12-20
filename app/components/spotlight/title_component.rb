# frozen_string_literal: true

module Spotlight
  # Draws the title in the masthead
  class TitleComponent < ViewComponent::Base
    def initialize(title:, subtitle:)
      @title = title
      @subtitle = subtitle
      super
    end

    def title
      tag.h1 @title, class: 'site-title h2'
    end

    def subtitle
      return unless @subtitle

      tag.small(@subtitle, class: 'd-none d-md-block py-2 fs-4')
    end
  end
end
