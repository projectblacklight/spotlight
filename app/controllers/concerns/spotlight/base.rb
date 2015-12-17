module Spotlight
  ##
  # Base controller mixin
  module Base
    extend ActiveSupport::Concern

    include Blacklight::Base
    include Spotlight::Config

    # This overwrites Blacklight::Configurable#blacklight_config
    def blacklight_config
      exhibit_specific_blacklight_config
    end

    def autocomplete_json_response(document_list)
      document_list.map do |doc|
        autocomplete_json_response_for_document doc
      end
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def autocomplete_json_response_for_document(doc)
      {
        id: doc.id,
        title: CGI.unescapeHTML(view_context.presenter(doc).document_heading.to_str),
        thumbnail: doc.first(blacklight_config.index.thumbnail_field),
        thumbnails: doc.spotlight_image_versions.try(:thumb) || doc[blacklight_config.index.thumbnail_field],
        full_image_url: doc.spotlight_image_versions.try(:full).try(:first),
        full_images: doc.spotlight_image_versions.try(:full),
        image_versions: doc.spotlight_image_versions.image_versions(:thumb, :full),
        description: doc.id,
        url: exhibit_catalog_path(current_exhibit, doc),
        private: doc.private?(current_exhibit),
        global_id: doc.to_global_id.to_s
      }
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  end
end
