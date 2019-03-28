# frozen_string_literal: true

module Spotlight
  ##
  # Helpers used by the theme functionality
  module ThemeHelper
    def themed_stylesheet_link_tag(tag)
      return stylesheet_link_tag(tag) if current_theme.nil?

      if Spotlight::Engine.config.exhibit_themes.include?(current_theme)
        stylesheet_link_tag "#{tag}_#{current_theme}"
      else
        Rails.logger.warn "Exhibit theme '#{current_theme}' not in white-list of available themes: #{Spotlight::Engine.config.exhibit_themes}"
        stylesheet_link_tag(tag)
      end
    end

    def current_exhibit_theme
      Deprecation.warn self, 'current_exhibit_theme has been deprecated and will be removed in Spotlight 3.0.  '\
                             'Use current_theme instead.'
      current_theme
    end

    def current_theme
      # prioritize exhibit themes over site-wide themes
      if current_exhibit && current_exhibit.theme.present?
        current_exhibit.theme
      elsif current_site.theme.present?
        current_site.theme
      end
    end

    def render_themed_partial(partial)
      return render partial: partial if current_theme.nil?

      if Spotlight::Engine.config.exhibit_themes.include?(current_theme)
        render partial: "#{partial}_#{current_theme}"
      else
        Rails.logger.warn "Exhibit theme '#{current_theme}' not in white-list "\
                          "of available themes: #{Spotlight::Engine.config.exhibit_themes}"
        render partial: partial
      end
    end
  end
end
