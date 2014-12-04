module Spotlight
  module Base
    extend ActiveSupport::Concern

    include Blacklight::Base
    include Spotlight::Config

    # This overwrites Blacklight::Configurable#blacklight_config
    def blacklight_config
      exhibit_specific_blacklight_config
    end

    def autocomplete_json_response document_list
      document_list.map do |doc|
        {
          id: doc.id,
          title: view_context.presenter(doc).raw_document_heading,
          thumbnail: doc.first(blacklight_config.index.thumbnail_field),
          thumbnails: doc[blacklight_config.index.thumbnail_field],
          description: doc.id,
          url: exhibit_catalog_path(current_exhibit, doc),
          private: doc.private?(current_exhibit)
        }
      end
    end

  end
end
