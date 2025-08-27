# frozen_string_literal: true

module Spotlight
  module Analytics
    # Display Analytics
    class DashboardComponent < ViewComponent::Base
      attr_reader :current_exhibit, :dates

      def initialize(current_exhibit:)
        super()
        @current_exhibit = current_exhibit
        @default_start_date = [min_date, 1.year.ago].max
        @default_end_date = [max_date, Time.zone.today].min
      end

      def before_render
        flash[:error] = nil
        @dates = { 'start_date' => @default_start_date.to_date.to_s,
                   'end_date' => @default_end_date.to_date.to_s }

        validate_dates if params[:start_date] || params[:end_date]
      end

      def min_date
        Spotlight::Engine.config.ga_date_range['start_date'] || Date.new(2015, 8, 14) # This is the minimum date supported by GA
      end

      def max_date
        Spotlight::Engine.config.ga_date_range['end_date'] || Time.zone.today
      end

      def note
        I18n.t('spotlight.dashboards.analytics.note', default: nil)
      end

      def heading
        if params[:start_date] || params[:end_date]
          I18n.t('spotlight.dashboards.analytics.reporting_period_heading_dynamic', start_date: formatted_date(dates['start_date']),
                                                                                    end_date: formatted_date(dates['end_date']))
        else
          I18n.t('spotlight.dashboards.analytics.reporting_period_heading')
        end
      end

      def results?
        page_analytics.totals.to_h.present? || search_analytics.totals.to_h.present?
      end

      def page_url
        @page_url ||= helpers.exhibit_root_path(current_exhibit)
      end

      def page_analytics
        Rails.cache.fetch([current_exhibit, dates['start_date'], dates['end_date'], 'page_analytics'], expires_in: 1.hour) do
          current_exhibit.page_analytics(dates, page_url)
        end
      end

      def search_analytics
        Rails.cache.fetch([current_exhibit, dates['start_date'], dates['end_date'], 'search_analytics'], expires_in: 1.hour) do
          current_exhibit.analytics(dates, page_url)
        end
      end

      private

      def validate_dates
        @start_date = parse_date(params[:start_date], min_date)
        @end_date = parse_date(params[:end_date], max_date)
        if @start_date > @end_date
          flash[:error] = I18n.t('spotlight.dashboards.analytics.error_heading', date: "#{@start_date} to #{@end_date}")
        elsif @start_date < min_date
          flash[:error] = I18n.t('spotlight.dashboards.analytics.error_heading', date: @start_date)
        elsif @end_date > max_date
          flash[:error] = I18n.t('spotlight.dashboards.analytics.error_heading', date: @end_date)
        else
          update_dates
        end
      end

      def update_dates
        @dates['start_date'] = @start_date.to_date.to_s if parse_date(params[:start_date], nil)
        @dates['end_date'] = @end_date.to_date.to_s if parse_date(params[:end_date], nil)
      end

      def parse_date(date, backup_date)
        return backup_date unless date

        Date.parse(date)
      rescue Date::Error
        flash[:error] = I18n.t('spotlight.dashboards.analytics.error_heading', date:)
        backup_date
      end

      def formatted_date(date_string)
        Date.parse(date_string).strftime('%m/%d/%Y')
      end
    end
  end
end
