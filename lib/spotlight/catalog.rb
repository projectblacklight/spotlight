module Spotlight
  module Catalog
    extend ActiveSupport::Concern

    require 'spotlight/catalog/access_controls_enforcement'

    include Spotlight::Catalog::AccessControlsEnforcement

    def blacklight_config
      @blacklight_config ||= Exhibit.default.blacklight_config params.fetch(:view, :list)
    end
  end
end