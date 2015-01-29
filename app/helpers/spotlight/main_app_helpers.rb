module Spotlight::MainAppHelpers
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
  
  def enabled_in_spotlight_view_type_configuration? config
    return true unless current_exhibit

    return true if controller.is_a? Spotlight::PagesController

    return current_exhibit.blacklight_configuration.document_index_view_types.include? config.key.to_s
  end
  
  def field_enabled? field, *args
    field.enabled && field.send((:show if controller.is_a? Blacklight::Catalog and ["edit", "show"].include?(action_name)) || document_index_view_type)
  end

  def link_back_to_catalog(opts={:label=>nil})
    opts[:route_set] ||= spotlight if current_exhibit
    super
  end

  def render_save_search
    render('save_search') if render_save_this_search?
  end

  def render_save_this_search?
    (current_exhibit and can?( :curate, current_exhibit)) &&
    (params[:controller] != "spotlight_catalog_controller" && params[:action] != "admin")
  end

end
