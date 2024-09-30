# frozen_string_literal: true

module Spotlight
  ##
  # CRUD actions for the exhibit home page
  class HomePagesController < Spotlight::PagesController
    include Spotlight::Catalog

    load_and_authorize_resource through: :exhibit, singleton: true, instance_name: 'page'

    before_action :attach_breadcrumbs, except: :show

    helper_method :facet_limit_for, :search_facet_path

    def index
      redirect_to exhibit_feature_pages_path(@exhibit)
    end

    def show
      @response, @document_list = search_service.search_results if @page.display_sidebar?

      if @page.nil? || !@page.published?
        render '/catalog/index'
      else
        render 'show'
      end
    end

    def edit
      add_breadcrumb(t(:'spotlight.curation.sidebar.feature_pages'), exhibit_feature_pages_path(@exhibit))
      add_breadcrumb(@page.title, [:edit, @exhibit, @page])
      super
    end

    # We're oddly getting an unknown action
    # error w/o explicitly defining this here
    def clone
      super
    end

    # Copied from blacklight to avoid bringing in all of Blacklight::Catalog
    DEFAULT_FACET_LIMIT = 10

    # Look up facet limit for given facet_field. Will look at config, and
    # if config is 'true' will look up from Solr @response if available. If
    # no limit is available, returns nil. Used from #add_facetting_to_solr
    # to supply f.fieldname.facet.limit values in solr request (no @response
    # available), and used in display (with @response available) to create
    # a facet paginator with the right limit.
    def facet_limit_for(facet_field)
      facet = blacklight_config.facet_fields[facet_field]
      return if facet.blank?

      if facet.limit && @response && @response.aggregations[facet.field]
        limit = @response.aggregations[facet.field].limit

        if limit.nil? # we didn't get or a set a limit, so infer one.
          facet.limit if facet.limit != true
        elsif limit == -1 # limit -1 is solr-speak for unlimited
          nil
        else
          limit.to_i - 1 # we added 1 to find out if we needed to paginate
        end
      elsif facet.limit
        facet.limit == true ? DEFAULT_FACET_LIMIT : facet.limit
      end
    end

    private

    alias search_action_url exhibit_search_action_url
    alias search_facet_path exhibit_search_facet_path

    def load_locale_specific_page
      @page = Spotlight::HomePage.for_locale.find_by(exhibit: current_exhibit)
    end

    def allowed_page_params
      super.concat %i[display_title display_sidebar]
    end
  end
end
