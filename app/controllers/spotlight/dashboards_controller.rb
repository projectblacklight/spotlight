module Spotlight
  class DashboardsController < Spotlight::ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource :exhibit, class: Spotlight::Exhibit

    include Spotlight::Base
    include Spotlight::Catalog::AccessControlsEnforcement

    def show
      authorize! :curate, @exhibit

      @pages = @exhibit.pages.recent.limit(5)
      @solr_documents = load_recent_solr_documents 5
      add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), @exhibit
      add_breadcrumb t(:'spotlight.curation.sidebar.dashboard'), exhibit_dashboard_path(@exhibit)

      self.blacklight_config.view.reject! { |k,v| true }
      self.blacklight_config.view.admin_table.partials = ['index_compact']
      self.blacklight_config.view.admin_table.document_actions = []
    end

    def _prefixes
      @_prefixes ||= super + ['spotlight/catalog', 'catalog']
    end

    protected

    def load_recent_solr_documents count
      solr_params = { sort: "#{blacklight_config.index.timestamp_field} desc" }
      @response, docs = get_search_results(solr_params)
      docs.take(count)
    end
  end
end
