module Spotlight
  module Config
    extend ActiveSupport::Concern

    def exhibit_specific_blacklight_config
      @exhibit_specific_blacklight_config ||= if current_exhibit
        current_exhibit.blacklight_config
      else
        default_catalog_controller.blacklight_config.deep_copy
      end
    end
  end
end