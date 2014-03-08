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
end
