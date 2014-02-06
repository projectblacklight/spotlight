module Spotlight
  class BrowseController < Spotlight::ApplicationController
    include Blacklight::Base
    copy_blacklight_config_from ::CatalogController

    load_resource :exhibit, class: "Spotlight::Exhibit", only: [:index]
    
    def index
      @searches = @exhibit.searches.published
    end

    def show
      @search = Spotlight::Search.published.find(params[:id])
      (@response, @document_list) = get_search_results @search.query_params
    end
    
    def _prefixes
      @_prefixes ||= super + ['catalog']
    end
  end
end