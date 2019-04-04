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
      if current_exhibit_theme && current_exhibit.theme != 'default'
        stylesheet_link_tag "#{tag}_#{current_exhibit_theme}"
      else
        Rails.logger.warn "Exhibit theme '#{current_exhibit_theme}' not in white-list of available themes: #{Spotlight::Engine.config.exhibit_themes}"
        stylesheet_link_tag(tag)
      end
    end

    def current_exhibit_theme
      current_exhibit.theme if current_exhibit && current_exhibit.theme.present? && Spotlight::Engine.config.exhibit_themes.include?(current_exhibit.theme)
    end
  end
end
