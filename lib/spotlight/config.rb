module Spotlight
  module Config
    extend ActiveSupport::Concern

    def exhibit_specific_blacklight_config
      @exhibit_specific_blacklight_config ||=
        if current_exhibit || params[:exhibit_id]
          raise "Exhibit id exists (#{params[:exhibit_id]}), but @exhibit hasn't been loaded yet" unless current_exhibit
          current_exhibit.blacklight_config
        else
          # TODO Not in an exhibit context. (So why are we calling a method called exhibit_specific_blacklight_config)
          default_catalog_controller.blacklight_config.deep_copy
        end
    end
  end
end
