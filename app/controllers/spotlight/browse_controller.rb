module Spotlight
  ##
  # Index and read actions for browse (see {Spotlight::SearchesController}
  # for the curator's create-update-delete actions)
  class BrowseController < Spotlight::ApplicationController
    load_and_authorize_resource :exhibit, class: 'Spotlight::Exhibit'
    include Spotlight::Base

    load_and_authorize_resource :search, except: :index, through: :exhibit, parent: false
    before_action :attach_breadcrumbs
    record_search_parameters only: :show

    helper_method :should_render_spotlight_search_bar?

    def index
      @searches = @exhibit.searches.published
    end

    def show
      blacklight_config.index.document_actions = blacklight_config.browse.document_actions

      add_breadcrumb @search.title, exhibit_browse_path(@exhibit, @search)
      (@response, @document_list) = search_results(search_query)
    end

    protected

    def search_query
      base_query = Blacklight::SearchState.new(@search.query_params, blacklight_config)
      user_query = Blacklight::SearchState.new(params, blacklight_config).to_h
      base_query.params_for_search(user_query)
    end

    ##
    # Browsing an exhibit should start a new search session
    def start_new_search_session?
      params[:action] == 'show'
    end

    # WARNING: Blacklight::Catalog::SearchContext sets @searches in history_session in a before_filter
    # See https://github.com/projectblacklight/blacklight/pull/780
    def history_session
      # nop
    end

    def attach_breadcrumbs
      add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), @exhibit
      add_breadcrumb(@exhibit.main_navigations.browse.label_or_default, exhibit_browse_index_path(@exhibit))
    end

    def _prefixes
      @_prefixes ||= super + ['catalog']
    end

    def current_masthead
      if resource_masthead?
        @search.masthead
      else
        super
      end
    end

    def resource_masthead?
      @search && @search.masthead && @search.masthead.display?
    end

    def should_render_spotlight_search_bar?
      !resource_masthead?
    end
  end
end
