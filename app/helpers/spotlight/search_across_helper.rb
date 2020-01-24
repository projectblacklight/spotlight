# frozen_string_literal: true

module Spotlight
  # Helpers for search across functionality
  module SearchAcrossHelper
    def render_search_across_form?
      %w[search_across exhibits].include?(controller_name) && action_name == 'index'
    end
  end
end
