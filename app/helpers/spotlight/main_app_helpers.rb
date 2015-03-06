module Spotlight::MainAppHelpers
  include Spotlight::NavbarHelper
  def cache_key_for_spotlight_exhibits
    Spotlight::Exhibit.maximum(:updated_at).try(:utc).try(:to_s, :number)
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
  
  def enabled_in_spotlight_view_type_configuration? config, *args
    if config.respond_to? :upstream_if and !config.upstream_if.nil?
      return false unless evaluate_configuration_conditional(config.upstream_if, config, *args)
    end

    return true unless current_exhibit

    return true if controller.is_a? Spotlight::PagesController

    return current_exhibit.blacklight_configuration.document_index_view_types.include? config.key.to_s
  end
  
  def field_enabled? field, *args
    return false unless field.enabled

    if field.respond_to? :upstream_if and !field.upstream_if.nil?
      return false unless evaluate_configuration_conditional(field.upstream_if, field, *args)
    end

    if field.is_a? Blacklight::Configuration::SortField
      field.enabled
    elsif field.is_a?(Blacklight::Configuration::FacetField) or (controller.is_a?(Blacklight::Catalog) and ["edit", "show"].include?(action_name))
      field.show
    else
      field.send(document_index_view_type)
    end
  end

  def link_back_to_catalog(opts={:label=>nil})
    if (current_search_session.try(:query_params) || {}).fetch(:controller, "").starts_with? "spotlight"
      opts[:route_set] ||= spotlight
    end
    super
  end
end
