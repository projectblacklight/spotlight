# frozen_string_literal: true

module Spotlight
  ##
  # Exhibit mixin to provide analytics data
  module ExhibitAnalytics
    def analytics(start_date = 1.month, path = nil)
      return OpenStruct.new unless analytics_provider&.enabled?

      @analytics ||= {}
      @analytics[start_date] ||= analytics_provider.exhibit_data(path || self, start_date: start_date.ago)
    end

    def page_analytics(start_date = 1.month, path = nil)
      return [] unless analytics_provider&.enabled?

      @page_analytics ||= {}
      @page_analytics[start_date] ||= analytics_provider.page_data(path || self, start_date: start_date.ago)
    end

    def analytics_provider
      @analytics_provider ||= Spotlight::Engine.config.analytics_provider.new
    end
  end
end
