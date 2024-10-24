# frozen_string_literal: true

module Spotlight
  ##
  # Exhibit mixin to provide analytics data
  module ExhibitAnalytics
    def analytics(dates = { start_date: '365daysAgo', end_date: 'today' }, path = nil)
      return OpenStruct.new unless analytics_provider&.enabled?

      analytics_provider.exhibit_data(path || self, dates)
    end

    def page_analytics(dates = { start_date: '365daysAgo', end_date: 'today' }, path = nil)
      return [] unless analytics_provider&.enabled?

      analytics_provider.page_data(path || self, dates)
    end

    def analytics_provider
      @analytics_provider ||= Spotlight::Engine.config.analytics_provider.new
    end
  end
end
