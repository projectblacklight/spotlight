module Spotlight
  module BrowseHelper
    include ::BlacklightConfigurationHelper
    def default_document_index_view_type
      (:gallery if blacklight_config.view.has_key? :gallery) || super
    end
  end
end
