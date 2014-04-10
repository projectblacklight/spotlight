module Spotlight::MainAppHelpers

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
    field.enabled && field.send((:show if controller.is_a? Blacklight::Catalog and action_name == "show") || document_index_view_type)
  end

end
