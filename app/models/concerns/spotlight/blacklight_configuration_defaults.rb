module Spotlight::BlacklightConfigurationDefaults
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
      default_fields = ::CatalogController.blacklight_config.sort_fields
      self.sort_fields = default_fields.each_with_object({}) do |(k, v), obj|
        obj[k] = { show: true }
      end
    end

    def default_view_types
      return true unless document_index_view_types.empty?

      # can't use default_blacklight_config until after the BlacklightConfiguration
      # is created or we run into a circular dependency.
      self.document_index_view_types = ::CatalogController.blacklight_config.view.keys.map(&:to_s)
    end

    def set_default_per_page
      # can't use default_blacklight_config until after the BlacklightConfiguration
      # is created or we run into a circular dependency.
      self.default_per_page ||= ::CatalogController.blacklight_config.per_page.first
    end

end
