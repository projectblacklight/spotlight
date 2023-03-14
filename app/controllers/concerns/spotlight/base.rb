# frozen_string_literal: true

module Spotlight
  ##
  # Base controller mixin
  module Base
    extend ActiveSupport::Concern

    include Blacklight::Configurable
    include Blacklight::SearchContext
    include Spotlight::Config

    included do
      helper_method :controller_tracking_method
    end

    def controller_tracking_method
      Spotlight::Engine.config.controller_tracking_method
    end

    # This overwrites Blacklight::Configurable#blacklight_config
    def blacklight_config
      exhibit_specific_blacklight_config
    end

    def autocomplete_json_response(document_list)
      document_list.map do |doc|
        autocomplete_json_response_for_document doc
      end
    end

    def autocomplete_json_response_for_document(doc)
      {
        id: doc.id,
        title: autocomplete_title(view_context.document_presenter(doc).heading),
        thumbnail: doc.first(blacklight_config.index.thumbnail_field),
        full_image_url: doc.first(Spotlight::Engine.config.full_image_field),
        description: doc.id,
        url: polymorphic_path([current_exhibit, doc]),
        private: doc.private?(current_exhibit),
        global_id: doc.to_global_id.to_s,
        iiif_manifest: doc[Spotlight::Engine.config.iiif_manifest_field]
      }
    end

    # Some pipeline steps may return an array instead of a string
    # to_str throws an error if the object is not a string
    # This workaround does a join on the array to allow values to be returned

    private
    
    def autocomplete_title(heading)
      heading = heading.join(',') if heading.is_a?(Array)
      CGI.unescapeHTML(heading.to_str)
    end
  end
end