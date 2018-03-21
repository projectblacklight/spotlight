module Spotlight
  ##
  # Index and read actions for browse (see {Spotlight::SearchesController}
  # for the curator's create-update-delete actions)
  class BrowseController < Spotlight::ApplicationController
    load_and_authorize_resource :exhibit, class: 'Spotlight::Exhibit'
    include Spotlight::Base
    include Blacklight::Facet

    load_and_authorize_resource :search, except: :index, through: :exhibit, parent: false
    before_action :attach_breadcrumbs
    before_action :attach_search_breadcrumb, only: :show
    record_search_parameters only: :show

    helper_method :should_render_spotlight_search_bar?

    before_action :swap_actions_configuration, only: :show

    def index
      @searches = @exhibit.searches.published
    end

    def show
      @response, @document_list = search_results(search_query)

      respond_to do |format|
        format.html
        format.json do
          @presenter = Blacklight::JsonPresenter.new(@response, @document_list, facets_from_request, blacklight_config)
          render template: 'catalog/index'
        end
      end
    end

    protected

    def swap_actions_configuration
      blacklight_config.index.document_actions = blacklight_config.browse.document_actions
    end

    def search_query
      @search.query_params['q'] = [@search.query_params['q'], params[:browse_q]].join(' ')
      @search.merge_params_for_search(params, blacklight_config)
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
      add_breadcrumb t(:'spotlight.curation.nav.home', title: @exhibit.title), @exhibit
      add_breadcrumb(@exhibit.main_navigations.browse.label_or_default, exhibit_browse_index_path(@exhibit))
    end

    def attach_search_breadcrumb
      add_breadcrumb @search.title, exhibit_browse_path(@exhibit, @search)
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
