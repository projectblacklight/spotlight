module Spotlight
  ##
  # Helper for browse views
  module BrowseHelper
    include ::BlacklightConfigurationHelper

    ##
    # Override Blacklight's #default_document_index_view_type helper to
    # use a different default view when presenting browse categories
    def default_document_index_view_type
      # rubocop:disable Style/DeprecatedHashMethods
      (:gallery if blacklight_config.view.has_key? :gallery) || super
      # rubocop:enable Style/DeprecatedHashMethods
    end
  end
end
