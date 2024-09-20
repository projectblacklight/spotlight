# frozen_string_literal: true

module Spotlight
  # Displays the document
  # This overrides the title method to provide an edit link.
  class DocumentAdminTableComponent < Blacklight::DocumentComponent
    def initialize(component: 'tr', **kwargs)
      super
    end

    def classes
      super + ['doc-row']
    end

    def timestamp
      return unless presenter.document[presenter.configuration.index.timestamp_field]

      l Date.parse(presenter.document[presenter.configuration.index.timestamp_field])
    rescue StandardError
      nil
    end
  end
end
