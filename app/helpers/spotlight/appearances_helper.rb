module Spotlight
  module AppearancesHelper
    def translate_sort_fields(sort_config)
      if sort_config[:sort]
        safe_join(sort_config[:sort].split(',').map do |sort|
          sort_field, sort_order = sort.split(' ')
          safe_join([
            t(:"spotlight.appearances.edit.sort_fields.sort_keys.#{sort_field}"),
            t(:"spotlight.appearances.edit.sort_fields.sort_keys.#{sort_order}")
          ], " ")
        end, ", ")
      end
    end
  end
end
