# frozen_string_literal: true

module Spotlight
  # Allows component addition to exhibit navbar
  class EditViewLinksComponent < ViewComponent::Base
    attr_reader :page, :classes, :delete_link

    def initialize(page:, classes: 'page-links', delete_link: false)
      super()

      @page = page
      @classes = classes
      @delete_link = delete_link
    end
  end
end
