# frozen_string_literal: true

module Spotlight
  # Saved search helpers
  module SearchesHelper
    def available_document_index_views
      blacklight_config.view.to_h.reject { |_k, v| v.if == false }
    end
  end
end
