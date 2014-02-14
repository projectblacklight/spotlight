module Spotlight
  class AboutPagesController < PagesController
    protected
    def attach_breadcrumbs
      super
      if @page
        add_breadcrumb t(:'spotlight.curation.about_pages.nav_link'), @exhibit.main_about_page
        add_breadcrumb @page.title, @page unless @page == @exhibit.main_about_page
      end
    end
  end
end
