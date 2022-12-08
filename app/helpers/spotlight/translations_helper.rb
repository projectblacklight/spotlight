# frozen_string_literal: true

module Spotlight
  ##
  # Helper module for the Translations admin UI
  module TranslationsHelper
    def non_custom_metadata_fields
      custom_field_keys = current_exhibit.custom_fields.pluck(:field)

      current_exhibit.blacklight_config.show_fields.except(*custom_field_keys)
    end
  end
end
