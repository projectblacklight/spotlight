# frozen_string_literal: true

module Spotlight
  ##
  # Spotlight catalog mixins
  module Catalog
    extend ActiveSupport::Concern
    include Spotlight::Base
    include Spotlight::SearchHelper

    included do
      before_action :add_facet_visibility_field
    end

    # Adds a facet to display document visibility for the current exhibit
    # if the user is a curator
    # rubocop:disable Metrics/MethodLength
    def add_facet_visibility_field
      return unless current_exhibit && can?(:curate, current_exhibit)

      blacklight_config.add_facet_field 'exhibit_visibility',
                                        label: I18n.t(:'spotlight.catalog.facets.exhibit_visibility.label'),
                                        query: {
                                          public: {
                                            label: I18n.t(:'spotlight.catalog.facets.exhibit_visibility.public'),
                                            fq: "-#{blacklight_config.document_model.visibility_field(current_exhibit)}:false"
                                          },
                                          private: {
                                            label: I18n.t(:'spotlight.catalog.facets.exhibit_visibility.private'),
                                            fq: "#{blacklight_config.document_model.visibility_field(current_exhibit)}:false"
                                          }
                                        }
    end
    # rubocop:enable Metrics/MethodLength

    def render_curator_actions?
      current_exhibit && can?(:curate, current_exhibit) &&
        !(params[:controller] == 'spotlight/catalog' && params[:action] == 'admin')
    end
  end
end
