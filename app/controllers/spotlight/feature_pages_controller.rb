module Spotlight
  class FeaturePagesController < PagesController
    protected
    def attach_breadcrumbs
      super

      if action_name == 'edit'
        add_breadcrumb t(:'spotlight.curation.sidebar.feature_pages'), exhibit_feature_pages_path(@exhibit)
      end

      if @page
        add_breadcrumb @page.parent_page.title, @page.parent_page unless @page.top_level_page?
        add_breadcrumb @page.title, action_name == 'edit' ? edit_feature_page_path(@page) : @page
      elsif action_name == 'index'
        add_breadcrumb t(:'spotlight.curation.sidebar.header'), exhibit_dashboard_path(@exhibit)
        add_breadcrumb t(:'spotlight.curation.sidebar.feature_pages'), exhibit_feature_pages_path(@exhibit)
      end
    end
  end
end
