# frozen_string_literal: true

module Spotlight
  # Blacklight Skip Link Component with conditional search link for Spotlight
  class SkipLinkComponent < Blacklight::SkipLinkComponent
    def initialize(render_search_link: true)
      @render_search_link = render_search_link

      super
    end

    def link_to_search
      super if @render_search_link
    end
  end
end
