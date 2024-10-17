# frozen_string_literal: true

module Spotlight
  ##
  # Controller enabling bulk functionality for search results
  class BulkActionsController < Spotlight::CatalogController
    before_action :authenticate_user!
    before_action :check_authorization

    def add_tags
      handle_bulk_action_with_job(Spotlight::AddTagsJob, tags: add_tags_params)
    end

    def remove_tags
      handle_bulk_action_with_job(Spotlight::RemoveTagsJob, tags: remove_tags_params)
    end

    def change_visibility
      handle_bulk_action_with_job(Spotlight::ChangeVisibilityJob, visibility: change_visibility_params)
    end

    private

    def handle_bulk_action_with_job(job, i18n_key: action_name, **params)
      job.perform_later(
        solr_params:,
        exhibit: current_exhibit,
        user: current_user,
        **params
      )

      redirect_back fallback_location: spotlight.search_exhibit_catalog_path(current_search_session.query_params),
                    notice: t(:"spotlight.bulk_actions.#{i18n_key}.changed", count: solr_response.total)
    end

    def solr_params
      solr_response.request_params
    end

    def solr_response
      @solr_response ||= begin
        response, _docs = search_service.search_results do |builder|
          builder.merge(fl: 'id', rows: 0)
        end

        response
      end
    end

    def add_tags_params
      params.require(:tags).split(',').map(&:strip)
    end

    def remove_tags_params
      params.require(:tags).split(',').map(&:strip)
    end

    def change_visibility_params
      params.require(:visibility)
    end
  end
end
