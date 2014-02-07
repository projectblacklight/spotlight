module Spotlight
  module Catalog
    def blacklight_config
      @blacklight_config ||= Exhibit.default.blacklight_config params.fetch(:view, :list)
    end
  end
end