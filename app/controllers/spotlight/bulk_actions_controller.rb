# frozen_string_literal: true

module Spotlight
  ##
  # Controller enabling bulk functionality for search results
  class BulkActionsController < Spotlight::CatalogController
    before_action :authenticate_user!
    before_action :check_authorization

    # rubocop:disable Metrics/MethodLength
    def add_tags
      solr_params = nil
      # Get the total number of results
      (response,) = search_service.search_results do |builder|
        builder.merge(fl: 'id', rows: 1)
        solr_params = builder.to_h
      end

      Spotlight::AddTagsJob.perform_later(
        solr_params: solr_params,
        exhibit: current_exhibit,
        tags: tags_param,
        user: current_user
      )

      redirect_back fallback_location: fallback_url,
                    notice: t(:'spotlight.bulk_actions.add_tags.changed', count: response.total)
    end
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/MethodLength
    def visibility
      solr_params = nil
      # Get the total number of results
      (response,) = search_service.search_results do |builder|
        builder.merge(fl: 'id', rows: 1)
        solr_params = builder.to_h
      end

      Spotlight::ChangeVisibilityJob.perform_later(
        solr_params: solr_params,
        exhibit: current_exhibit,
        visibility: visibility_param,
        user: current_user
      )

      redirect_back fallback_location: fallback_url,
                    notice: t(:'spotlight.bulk_actions.change_visibility.changed', count: response.total)
    end
    # rubocop:enable Metrics/MethodLength

    def tags_param
      params.require(:tags).split(',')
    end

    def visibility_param
      params.require(:visibility)
    end

    def fallback_url
      spotlight.search_exhibit_catalog_path(current_search_session.query_params)
    end
  end
end
