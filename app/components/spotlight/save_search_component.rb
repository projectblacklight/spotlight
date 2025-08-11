# frozen_string_literal: true

module Spotlight
  # Displays the "Save this search" button and modal
  class SaveSearchComponent < ViewComponent::Base
    def initialize(button_classes: 'btn btn-outline-primary')
      @button_classes = button_classes
      super()
    end

    attr_reader :button_classes

    delegate :search_state, :current_exhibit, to: :helpers
    delegate :searches, to: :current_exhibit

    def button
      button_tag t(:'spotlight.saved_search.label'), id: 'save-this-search', class: button_classes,
                                                     data: { 'bs-toggle': 'modal', 'bs-target': '#save-modal' }
    end

    def form_path
      [helpers.spotlight, current_exhibit, Spotlight::Search.new]
    end
  end
end
