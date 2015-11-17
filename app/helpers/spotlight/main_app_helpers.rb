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

    def enabled_in_spotlight_view_type_configuration?(config, *args)
      case
      when config.respond_to?(:upstream_if) && !config.upstream_if.nil? && !evaluate_configuration_conditional(config.upstream_if, config, *args)
        false
      when current_exhibit.nil? || controller.is_a?(Spotlight::PagesController)
        true
      else
        current_exhibit.blacklight_configuration.document_index_view_types.include? config.key.to_s
      end
    end

    # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength
    def field_enabled?(field, *args)
      case
      when !field.enabled
        false
      when (field.respond_to?(:upstream_if) && !field.upstream_if.nil? && !evaluate_configuration_conditional(field.upstream_if, field, *args))
        false
      when field.is_a?(Blacklight::Configuration::SortField) || field.is_a?(Blacklight::Configuration::SearchField)
        field.enabled
      when field.is_a?(Blacklight::Configuration::FacetField) || (controller.is_a?(Blacklight::Catalog) && %w(edit show).include?(action_name))
        field.show
      else
        field.send(document_index_view_type)
      end
    end
    # rubocop:enable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength

    def link_back_to_catalog(opts = { label: nil })
      if (current_search_session.try(:query_params) || {}).fetch(:controller, '').starts_with? 'spotlight'
        opts[:route_set] ||= spotlight
      end
      super
    end
  end
end
