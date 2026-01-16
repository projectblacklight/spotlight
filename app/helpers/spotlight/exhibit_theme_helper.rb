# frozen_string_literal: true

module Spotlight
  ##
  # Exhibit theme/stylesheet helper
  module ExhibitThemeHelper
    def exhibit_stylesheet_link_tag(tag)
      if current_exhibit_theme && current_exhibit&.theme != 'default'
        stylesheet_link_tag "#{tag}_#{current_exhibit_theme}"
      else
        Rails.logger.debug { "Exhibit theme '#{current_exhibit_theme}' not in the list of available themes: #{current_exhibit&.themes}" }
        stylesheet_link_tag(tag)
      end
    end

    def current_exhibit_theme
      current_exhibit.theme if current_exhibit && current_exhibit.theme.present? && current_exhibit.themes.include?(current_exhibit.theme)
    end
  end
end
