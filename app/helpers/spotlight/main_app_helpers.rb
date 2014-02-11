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

    document.exhibit_specific_field(current_exhibit, field)
  end
end