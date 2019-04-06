# frozen_string_literal: true

module Spotlight
  ##
  # Helpers that are injected into the main application (because they used in layouts)
  module MainAppHelpers
    include Spotlight::NavbarHelper
    def cache_key_for_spotlight_exhibits
      "#{Spotlight::Exhibit.count}/#{Spotlight::Exhibit.maximum(:updated_at).try(:utc)}"
    end

    def on_browse_page?
      params[:controller] == 'spotlight/browse'
    end

    def on_about_page?
      params[:controller] == 'spotlight/about_pages'
    end

    def show_contact_form?
      current_exhibit && (Spotlight::Engine.config.default_contact_email || current_exhibit.contact_emails.confirmed.any?)
    end

    def link_back_to_catalog(opts = { label: nil })
      if (current_search_session.try(:query_params) || {}).fetch(:controller, '').starts_with? 'spotlight'
        opts[:route_set] ||= spotlight
      end
      super
    end

    def presenter(document)
      case action_name
      when 'index'
        super
      else
        show_presenter(document)
      end
    end

    def exhibit_stylesheet_link_tag(tag)
      Deprecation.warn self, 'exhibit_stylesheet_link_tag has been deprecated and will be removed in Spotlight 3.0.  '\
                             'Use themed_stylesheet_link_tag instead.'
      themed_stylesheet_link_tag(tag)
    end

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
  end
end
