module Spotlight
  module BlacklightConfigurationsHelper
    def translate_sort_fields(sort_config)
      return unless sort_config[:sort]

      sort_config[:sort].split(',').map do |sort|
        sort_field, sort_order = sort.split(' ')
        safe_join([
          t(:"spotlight.blacklight_configurations.edit_sort_fields.sort_keys.#{sort_field.strip}"),
          t(:"spotlight.blacklight_configurations.edit_sort_fields.sort_keys.#{sort_order.strip}")
        ], ' ')
      end.to_sentence
    end
  end
end
