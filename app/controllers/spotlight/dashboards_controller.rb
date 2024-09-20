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
      blacklight_config.action_mapping&.delete(:show)
      blacklight_config.action_mapping.show.top_level_config = :index if blacklight_config.key?(:action_mapping)

      blacklight_config.index.document_component = Spotlight::DocumentAdminTableComponent
      blacklight_config.index.document_actions = []
      if Blacklight::VERSION > '8'
        blacklight_config.track_search_session.storage = false
      else
        blacklight_config.track_search_session = false
      end
    end

    def show
      authorize! :curate, @exhibit

      @pages = @exhibit.pages.recent.limit(5)
      @solr_documents = load_recent_solr_documents 5
      @recent_reindexing = @exhibit.job_trackers.where.not(job_class: Spotlight::Engine.config.hidden_job_classes).recent

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
      @response, _docs = search_service.search_results do |builder|
        builder.merge(solr_params)
      end
      @response.documents.take(count)
    end
  end
end
