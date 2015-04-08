module Spotlight
  ##
  # Helpers to provide default blacklight configuration values
  module BlacklightConfigurationDefaults
    extend ActiveSupport::Concern

    included do
      before_create :setup_defaults
    end

    protected

    def setup_defaults
      default_sort_fields
      default_view_types
      set_default_per_page
    end

    def default_sort_fields
      return true unless sort_fields.empty?

      # can't use default_blacklight_config until after the BlacklightConfiguration
      # is created or we run into a circular dependency.
      default_fields = Spotlight::Engine.blacklight_config.sort_fields
      self.sort_fields = default_fields.each_with_object({}) do |(k, _v), obj|
        obj[k] = { show: true }
      end
    end

    def default_view_types
      return true unless document_index_view_types.empty?

      # can't use default_blacklight_config until after the BlacklightConfiguration
      # is created or we run into a circular dependency.
      self.document_index_view_types = Spotlight::Engine.blacklight_config.view.keys.map(&:to_s)
    end

    def set_default_per_page
      # can't use default_blacklight_config until after the BlacklightConfiguration
      # is created or we run into a circular dependency.
      self.default_per_page ||= Spotlight::Engine.blacklight_config.per_page.first
    end
  end
end
