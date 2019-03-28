# frozen_string_literal: true

module Spotlight
  ##
  # Helpers that are injected into the main application (because they used in layouts)
  module MainAppHelpers
    include Spotlight::NavbarHelper
    include Spotlight::MastheadHelper
    include Spotlight::ThemeHelper

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
      opts[:route_set] ||= spotlight if (current_search_session&.query_params || {}).fetch(:controller, '').starts_with? 'spotlight'
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
  end
end
