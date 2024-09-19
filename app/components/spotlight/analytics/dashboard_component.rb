# frozen_string_literal: true

module Spotlight
  module Analytics
    # Display Analytics
    class DashboardComponent < ViewComponent::Base
      attr_reader :current_exhibit, :dates

      def initialize(current_exhibit:)
        super
        @current_exhibit = current_exhibit
        @dates = { 'start_date' => '365daysAgo', 'end_date' => 'today' }
      end

      def results?
        page_analytics.totals.to_h.present? || search_analytics.totals.to_h.present?
      end

      def page_url
        @page_url ||= helpers.exhibit_root_path(current_exhibit)
      end

      def page_analytics
        @page_analytics ||= current_exhibit.page_analytics(dates, page_url)
      end

      def search_analytics
        @search_analytics ||= current_exhibit.analytics(dates, page_url)
      end
    end
  end
end
