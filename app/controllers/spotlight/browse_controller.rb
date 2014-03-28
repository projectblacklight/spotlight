module Spotlight
  class BrowseController < Spotlight::ApplicationController
    load_resource :exhibit, class: "Spotlight::Exhibit"
    include Spotlight::Base
    include Spotlight::Catalog::AccessControlsEnforcement

    load_and_authorize_resource :search, except: :index, through: :exhibit, parent: false
    before_filter :attach_breadcrumbs
    record_search_parameters only: :show
    
    def index
      @searches = @exhibit.searches.published
    end

    def show
      add_breadcrumb @search.title, exhibit_browse_path(@exhibit, @search)
      (@response, @document_list) = get_search_results @search.query_params.with_indifferent_access.merge(params)
    end
    
    protected
    ##
    # Browsing an exhibit should start a new search session
    def start_new_search_session?
      params[:action] == 'show'
    end

    # WARNING: Blacklight::Catalog::SearchContext sets @searches in history_session in a before_filter
    # See https://github.com/projectblacklight/blacklight/pull/780
    def history_session
      #nop
    end

    def attach_breadcrumbs
      add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), @exhibit
      add_breadcrumb t(:'spotlight.browse.nav_link'), exhibit_browse_index_path(@exhibit)
    end

    def _prefixes
      @_prefixes ||= super + ['catalog']
    end
  end
end
