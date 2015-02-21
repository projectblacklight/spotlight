module Spotlight
  module BlacklightConfigurationsHelper
    def translate_sort_fields(sort_config)
      if sort_config[:sort]
        safe_join(sort_config[:sort].split(',').map do |sort|
          sort_field, sort_order = sort.split(' ')
          safe_join([
            t(:"spotlight.blacklight_configurations.edit_sort_fields.sort_keys.#{sort_field}"),
            t(:"spotlight.blacklight_configurations.edit_sort_fields.sort_keys.#{sort_order}")
          ], " ")
        end, ", ")
      end
    end
  end
end
