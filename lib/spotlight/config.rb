module Spotlight
  module Config
    extend ActiveSupport::Concern

    def exhibit_specific_blacklight_config
      @exhibit_specific_blacklight_config ||=
        if current_exhibit
          current_exhibit.blacklight_config
        elsif params[:exhibit_id]
          raise "Exhibit id exists (#{params[:exhibit_id]}), but @exhibit hasn't been loaded yet" unless current_exhibit
        else
          # Not in an exhibit context. (So why are we calling a method called exhibit_specific_blacklight_config)
          raise "Exhibit not found"
        end
    end
  end
end
