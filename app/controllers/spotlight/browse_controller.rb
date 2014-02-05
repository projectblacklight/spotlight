module Spotlight
  class BrowseController < Spotlight::ApplicationController
    include Blacklight::Base
    copy_blacklight_config_from ::CatalogController

    load_resource :exhibit, class: "Spotlight::Exhibit", only: [:index]
    load_resource class: "Spotlight::Search", only: [:show]

    def index
      @searches = @exhibit.searches
    end

    def show
      (@response, @document_list) = get_search_results @browse.query_params
    end
    
    def _prefixes
      @_prefixes ||= super + ['catalog']
    end
  end
end