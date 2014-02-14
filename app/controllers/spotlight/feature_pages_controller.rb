module Spotlight
  class FeaturePagesController < PagesController
    protected
    def attach_breadcrumbs
      super
      if @page
        add_breadcrumb @page.parent_page.title, @page.parent_page unless @page.top_level_page?
        add_breadcrumb @page.title, @page
      end
    end
  end
end
