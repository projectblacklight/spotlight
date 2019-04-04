# frozen_string_literal: true

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
        title: CGI.unescapeHTML(view_context.presenter(doc).heading.to_str),
        thumbnail: doc.first(blacklight_config.index.thumbnail_field),
        full_image_url: doc.first(Spotlight::Engine.config.full_image_field),
        description: doc.id,
        url: polymorphic_path([current_exhibit, doc]),
        private: doc.private?(current_exhibit),
        global_id: doc.to_global_id.to_s,
        iiif_manifest: doc[Spotlight::Engine.config.iiif_manifest_field]
      }
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  end
end
