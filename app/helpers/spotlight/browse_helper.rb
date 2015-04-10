module Spotlight
  ##
  # Helper for browse views
  module BrowseHelper
    include ::BlacklightConfigurationHelper

    ##
    # Override Blacklight's #default_document_index_view_type helper to
    # use a different default view when presenting browse categories
    def default_document_index_view_type
      (default_browse_index_view_type if blacklight_config.view.key? default_browse_index_view_type) || super
    end

    private

    def default_browse_index_view_type
      Spotlight::Engine.config.default_browse_index_view_type
    end
  end
end
