module Spotlight
  class HomePagesController < Spotlight::PagesController
    include Blacklight::SolrHelper

    load_resource :exhibit, class: Spotlight::Exhibit, only: [:show]
    load_and_authorize_resource through: :exhibit, shallow: true, singleton: true, instance_name: 'page'

    before_filter :attach_breadcrumbs

    skip_authorize_resource only: :show

    def edit
      add_breadcrumb t(:'spotlight.curation.sidebar.feature_pages'), exhibit_feature_pages_path(@exhibit)
      add_breadcrumb @page.title, [:edit, @exhibit, @page]
      super
    end

    def index
      redirect_to exhibit_feature_pages_path(@exhibit)
    end

    def show
      @page = @exhibit.home_page
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
      elsif current_exhibit
        current_exhibit.blacklight_config
      else
        super
      end
    end
  end
end
