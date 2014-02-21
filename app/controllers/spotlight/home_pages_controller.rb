module Spotlight
  class HomePagesController < Spotlight::PagesController
    include Blacklight::SolrHelper
    include Spotlight::PagesHelper

    skip_authorize_resource only: :show

    def edit
      add_breadcrumb t(:'spotlight.curation.sidebar.feature_pages'), exhibit_feature_pages_path(@exhibit)
      add_breadcrumb home_page_or_default_title(@page), edit_home_page_path(@page)
      super
    end

    def index
      redirect_to exhibit_feature_pages_path(@exhibit)
    end

    def show
      (@response, @document_list) = get_search_results

      if @page.nil? or !@page.published?
        render '/catalog/index'
      else
        render 'show'
      end
    end

    def _prefixes
      @_prefixes ||= super + ['catalog']
    end
    
    private

    def search_action_url *args
      exhibit_catalog_index_url(@page.exhibit, *args)
    end

    def blacklight_config
      if @page
        @page.exhibit.blacklight_config
      else 
        Spotlight::Exhibit.default.blacklight_config
      end
    end
  end
end
