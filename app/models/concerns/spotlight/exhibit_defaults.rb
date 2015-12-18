module Spotlight
  # Mixin for adding default configuration to exhibits
  module ExhibitDefaults
    extend ActiveSupport::Concern

    included do
      before_create :build_home_page
      before_create :add_site_reference
      after_create :initialize_config
      after_create :initialize_browse
      after_create :initialize_main_navigation
    end

    protected

    def initialize_config
      self.blacklight_configuration ||= Spotlight::BlacklightConfiguration.create!
    end

    def initialize_browse
      return unless searches.blank?

      searches.create title: 'All Exhibit Items',
                      long_description: 'All items in this exhibit.'
    end

    def initialize_main_navigation
      default_main_navigations.each_with_index do |nav_type, weight|
        main_navigations.create nav_type: nav_type, weight: weight
      end
    end

    def add_site_reference
      self.site ||= Spotlight::Site.instance
    end

    private

    def default_main_navigations
      Spotlight::Engine.config.exhibit_main_navigation.dup
    end
  end
end
