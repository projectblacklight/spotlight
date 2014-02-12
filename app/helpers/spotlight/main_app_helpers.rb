module Spotlight::MainAppHelpers

  def on_browse_page?
    params[:controller] == 'spotlight/browse'
  end

  def on_about_page?
    params[:controller] == 'spotlight/about_pages'
  end

  def exhibit_specific_field opts = {}
    document = opts[:document]
    field = opts[:field]

    document.sidecar(current_exhibit).data[field]
  end
  
  def should_render_index_field? document, solr_field
    super || document.sidecar(current_exhibit).has_key?(solr_field.field)
  end

  def should_render_show_field? document, solr_field
    super || document.sidecar(current_exhibit).has_key?(solr_field.field)
  end
end