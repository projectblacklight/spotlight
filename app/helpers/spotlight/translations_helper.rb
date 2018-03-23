module Spotlight
  ##
  # Helper module for the Translations admin UI
  module TranslationsHelper
    def non_custom_metadata_fields
      custom_field_keys = current_exhibit.custom_fields.pluck(:field)

      current_exhibit.blacklight_config.show_fields.reject do |key, _|
        custom_field_keys.include?(key)
      end
    end
  end
end
