# frozen_string_literal: true

module Spotlight
  ##
  # Exhibit dashboard controller
  class DashboardsController < Spotlight::ApplicationController
    before_action :authenticate_user!
    load_and_authorize_resource :exhibit, class: Spotlight::Exhibit

    include Spotlight::Base
    include Spotlight::SearchHelper

    before_action only: [:show] do
      blacklight_config.view.reject! { |_k, _v| true }
      blacklight_config.view.admin_table.partials = ['index_compact']
      blacklight_config.view.admin_table.document_actions = []
      blacklight_config.track_search_session = false
    end

    def show
      authorize! :curate, @exhibit

      @pages = @exhibit.pages.recent.limit(5)
      @solr_documents = load_recent_solr_documents 5
      @recent_reindexing = @exhibit.reindexing_log_entries.recent

      attach_dashboard_breadcrumbs
    end

    def analytics
      authorize! :curate, @exhibit

      attach_analytics_breadcrumbs
    end

    def _prefixes
      @_prefixes ||= super + ['spotlight/catalog', 'catalog']
    end

    protected

    def attach_analytics_breadcrumbs
      add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), @exhibit
      add_breadcrumb t(:'spotlight.curation.sidebar.analytics'), analytics_exhibit_dashboard_path(@exhibit)
    end

    def attach_dashboard_breadcrumbs
      add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), @exhibit
      add_breadcrumb t(:'spotlight.curation.sidebar.dashboard'), exhibit_dashboard_path(@exhibit)
    end

    def load_recent_solr_documents(count)
      solr_params = { sort: "#{blacklight_config.index.timestamp_field} desc" }
      @response, docs = search_service.search_results do |builder|
        builder.merge(solr_params)
      end
      docs.take(count)
    end
  end
end
