# frozen_string_literal: true

module Spotlight
  module SearchAcrossHelper
    def render_search_across_form?
      %w[search_across exhibits].include?(controller_name) && action_name == 'index'
    end
  end
end
