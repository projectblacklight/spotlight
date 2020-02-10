# frozen_string_literal: true

module Spotlight
  ##
  # Helper module for content in mastheads
  module MastheadHelper
    def masthead_heading_content
      return current_exhibit.title if current_exhibit

      application_name
    end

    def masthead_subheading_content
      return current_exhibit&.subtitle&.presence if current_exhibit

      current_site&.subtitle&.presence
    end
  end
end
