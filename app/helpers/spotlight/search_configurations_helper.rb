module Spotlight
  ##
  # Search configurations helpers
  module SearchConfigurationsHelper
    ##
    # Translate a sort field configuration into
    # a complete description of the sort
    def translate_sort_fields(sort_config)
      sort_description = sort_config[:sort_description] if sort_config[:sort_description]

      sort_description ||= sort_config[:sort].split(',').map do |sort|
        sort_field, sort_order = sort.split(' ')
        safe_join([
          t(:"spotlight.search_configurations.sort.keys.#{sort_field.strip}", default: sort_field.humanize.downcase),
          t(:"spotlight.search_configurations.sort.keys.#{sort_order.strip}", default: '')
        ], ' ')
      end.to_sentence if sort_config[:sort]

      sort_description
    end
  end
end
