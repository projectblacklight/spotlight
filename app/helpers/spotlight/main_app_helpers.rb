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
      current_exhibit && current_exhibit.contact_emails.confirmed.any?
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
  end
end
