module Spotlight
  ##
  # Helper for browse views
  module BrowseHelper
    include ::BlacklightConfigurationHelper
    include Spotlight::RenderingHelper

    def document_index_view_type
      if @search && @search.default_index_view_type.present? && params[:view].blank?
        blacklight_config.view[@search.default_index_view_type].key
      else
        super
      end
    end

    ##
    # Override Blacklight's #default_document_index_view_type helper to
    # use a different default view when presenting browse categories
    def default_document_index_view_type
      if view_available? default_browse_index_view_type
        default_browse_index_view_type
      else
        super
      end
    end

    ##
    # Get parent results count of a browse category search
    def parent_search_count
      @parent_search_count ||= Spotlight::Search.find(@search.id).count
    end

    private

    def view_available?(view)
      blacklight_config.view.key?(view) && blacklight_configuration_context.evaluate_if_unless_configuration(blacklight_config.view)
    end

    def default_browse_index_view_type
      Spotlight::Engine.config.default_browse_index_view_type
    end
  end
end
