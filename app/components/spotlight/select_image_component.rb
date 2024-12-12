# frozen_string_literal: true

module Spotlight
  # Component to select section of image
  class SelectImageComponent < ViewComponent::Base
    def initialize(document, exhibit, index_id)
      super
      @document = document
      @id = document.id
      @exhibit = exhibit
      @index_id = index_id
    end

    def render?
      true
    end

    def initial_crop_selection
      Spotlight::Engine.config.thumbnail_initial_crop_selection
    end

    def help_text
      t(:'spotlight.pages.form.instructions_html', thing: :thumbnail)
    end
  end
end
