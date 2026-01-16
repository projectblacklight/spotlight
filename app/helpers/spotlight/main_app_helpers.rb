# frozen_string_literal: true

module Spotlight
  ##
  # Helpers that are injected into the main application (because they used in layouts)
  module MainAppHelpers
    include Blacklight::DocumentHelperBehavior
    include Spotlight::ExhibitThemeHelper
    include Spotlight::NavbarHelper
    include Spotlight::MastheadHelper

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

    # Expecting to upstream this override in https://github.com/projectblacklight/blacklight/pull/3343/files
    def document_presenter(document, view_config: nil, **kwargs)
      (view_config&.document_presenter_class || document_presenter_class(document)).new(document, self, view_config:, **kwargs)
    end

    def document_presenter_class(_document)
      if action_name == 'index'
        super
      else
        blacklight_config.view_config(action_name: :show).document_presenter_class
      end
    end
  end
end
