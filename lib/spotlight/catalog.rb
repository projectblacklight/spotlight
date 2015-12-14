module Spotlight
  ##
  # Spotlight catalog mixins
  module Catalog
    extend ActiveSupport::Concern
    include Blacklight::Catalog
    include Spotlight::Base

    require 'spotlight/catalog/access_controls_enforcement'

    include Spotlight::Catalog::AccessControlsEnforcement

    included do
      before_action :add_facet_visibility_field
    end

    # Adds a facet to display document visibility for the current exhibit
    # if the user is a curator
    def add_facet_visibility_field
      return unless current_exhibit && can?(:curate, current_exhibit)
      blacklight_config.add_facet_field 'exhibit_visibility',
                                        label: I18n.t(:'spotlight.catalog.facets.exhibit_visibility.label'),
                                        query: {
                                          private: {
                                            label: I18n.t(:'spotlight.catalog.facets.exhibit_visibility.private'),
                                            fq: "#{blacklight_config.document_model.visibility_field(current_exhibit)}:false" }
                                        }
    end
  end
end
