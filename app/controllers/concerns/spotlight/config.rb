# frozen_string_literal: true

module Spotlight
  ##
  # Spotlight configuration methods
  module Config
    extend ActiveSupport::Concern

    def exhibit_specific_blacklight_config
      raise "Exhibit id exists (#{params[:exhibit_id]}), but @exhibit hasn't been loaded yet" if params[:exhibit_id] && current_exhibit.nil?
      raise 'Exhibit not found' unless current_exhibit

      @exhibit_specific_blacklight_config ||= current_exhibit.blacklight_config
    end
  end
end
