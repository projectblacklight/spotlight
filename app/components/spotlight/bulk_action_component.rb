# frozen_string_literal: true

module Spotlight
  # Displays the "Bulk actions" button and dropdown
  class BulkActionComponent < ViewComponent::Base
    def initialize(bulk_actions:, button_classes: 'btn btn-primary dropdown-toggle')
      @bulk_actions = bulk_actions
      @button_classes = button_classes
      super
    end

    attr_reader :button_classes, :bulk_actions

    def button
      button_tag t(:'spotlight.bulk_actions.label'), id: 'bulk-actions-button', class: button_classes,
                                                     data: { toggle: 'dropdown', 'bs-toggle': 'dropdown' },
                                                     aria: { haspopup: true, expanded: false }
    end
  end
end
