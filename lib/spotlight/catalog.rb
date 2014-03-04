module Spotlight
  module Catalog
    extend ActiveSupport::Concern
    include Blacklight::Catalog
    include Spotlight::Config

    require 'spotlight/catalog/access_controls_enforcement'

    include Spotlight::Catalog::AccessControlsEnforcement

    def blacklight_config
      exhibit_specific_blacklight_config
    end
  end
end
