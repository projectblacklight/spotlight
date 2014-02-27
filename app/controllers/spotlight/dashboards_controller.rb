module Spotlight
  class DashboardsController < Spotlight::ApplicationController
    include Blacklight::Base
    before_filter :authenticate_user!
    load_resource :exhibit, class: Spotlight::Exhibit

    copy_blacklight_config_from Spotlight::CatalogController

    def show
      authorize! :curate, @exhibit

      @pages = @exhibit.pages.recent.limit(5)
      @solr_documents = load_recent_solr_documents 5
      add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), @exhibit
      add_breadcrumb t(:'spotlight.curation.sidebar.dashboard'), exhibit_dashboard_path(@exhibit)

      self.blacklight_config.view.reject! { |k,v| true }
      self.blacklight_config.view.admin_table.partials = ['index_compact']
    end

    def _prefixes
      @_prefixes ||= super + ['spotlight/catalog', 'catalog']
    end

    protected

    def load_recent_solr_documents count
      solr_params = { sort: "#{blacklight_config.index.timestamp_field} desc" }
      @response = find(solr_params)
      @response.docs.take(count).map do |doc|
        ::SolrDocument.new(doc, @response)
      end
    end
  end
end
