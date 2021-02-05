# frozen_string_literal: true

module Spotlight
  ###
  class ChangeVisibilityJob < Spotlight::ApplicationJob
    def perform(solr_params:, exhibit:, visibility:, **)
      response = exhibit.blacklight_config.repository.search(solr_params.merge('rows' => 999_999_999))
      response.documents.each do |document|
        case visibility
        when 'public'
          document.make_public!(exhibit)
        when 'private'
          document.make_private!(exhibit)
        end
        document.reindex
      end
    end
  end
end
