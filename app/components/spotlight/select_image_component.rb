# frozen_string_literal: true

module Spotlight
  # Component to select section of image
  class SelectImageComponent < ViewComponent::Base
    def initialize(index_id, block_item_id)
      super
      @index_id = index_id
      @block_item_id = block_item_id
    end

    def render?
      true
    end

    def initial_crop_selection
      Spotlight::Engine.config.thumbnail_initial_crop_selection
    end

    def help_text
      t(:'spotlight.pages.form.instructions_html')
    end
  end
end
