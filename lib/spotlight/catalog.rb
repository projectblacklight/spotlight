module Spotlight
  module Catalog
    extend ActiveSupport::Concern

    require 'spotlight/catalog/access_controls_enforcement'

    include Spotlight::Catalog::AccessControlsEnforcement

    def blacklight_config
      if current_exhibit
        @blacklight_config ||= current_exhibit.blacklight_config params.fetch(:view, :list)
      else
        super
      end
    end
  end
end