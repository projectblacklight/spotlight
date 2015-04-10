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
      before_filter do
        if current_exhibit && can?(:curate, current_exhibit)
          blacklight_config.add_facet_field 'exhibit_visibility',
                                            label: I18n.t(:'spotlight.catalog.facets.exhibit_visibility.label'),
                                            query: {
                                              private: {
                                                label: I18n.t(:'spotlight.catalog.facets.exhibit_visibility.private'),
                                                fq: "#{Spotlight::SolrDocument.visibility_field(current_exhibit)}:false" }
                                            }
        end
      end
    end
  end
end
