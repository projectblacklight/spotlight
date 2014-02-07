module Spotlight
  class HomePagesController < Spotlight::PagesController
    include Blacklight::SolrHelper
    skip_authorize_resource only: :show

    def index
      redirect_to exhibit_feature_pages_path(@exhibit)
    end

    def show
      @page = @home_page = if params[:id]
        Spotlight::HomePage.find_by(id: params[:id])
      else
        Spotlight::Exhibit.default.home_page
      end

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
    def blacklight_config
      if @page
        @page.exhibit.blacklight_config
      else 
        Spotlight::Exhibit.default.blacklight_config
      end
    end

    def page_model
      :home_page
    end
    def cast_page_instance_variable
      if @home_pages
        @pages = @home_pages
      elsif @home_page
        @page = @home_page
      end
    end
  end
end