# frozen_string_literal: true

module Spotlight
  # Exhibit-specific custom search fields
  class CustomSearchField < ApplicationRecord
    serialize :configuration, Hash
    belongs_to :exhibit

    def label=(label)
      configuration['label'] = label

      update_blacklight_configuration_label label
    end

    def label
      conf = if slug && blacklight_configuration && blacklight_configuration.search_fields.key?(slug)
               blacklight_configuration.search_fields[slug].reverse_merge(configuration)
             else
               configuration
             end
      conf['label']
    end

    protected

    def blacklight_configuration
      exhibit&.blacklight_configuration
    end

    def update_blacklight_configuration_label(label)
      return unless slug && blacklight_configuration && blacklight_configuration.search_fields.key?(slug)

      blacklight_configuration.search_fields[slug]['label'] = label
      blacklight_configuration.save
    end
  end
end
