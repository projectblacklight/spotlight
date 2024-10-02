# frozen_string_literal: true

require 'signet/oauth_2/client'
require 'google/analytics/data'

module Spotlight
  module Analytics
    ##
    # Google Analytics data provider for the Exhibit dashboard
    class Ga
      def enabled?
        Spotlight::Engine.config.ga_json_key_path && client
      end

      def client
        Google::Analytics::Data.analytics_data do |config|
          config.credentials = Spotlight::Engine.config.ga_json_key_path
        end
      rescue StandardError => e
        Rails.logger.error(e)
        nil
      end

      def params(path, dates)
        {
          date_ranges: [{ start_date: dates['start_date'], end_date: dates['end_date'] }],
          metric_aggregations: [
            ::Google::Analytics::Data::V1beta::MetricAggregation::TOTAL
          ],
          property: "properties/#{ga_property_id}",
          dimension_filter: dimension_filter(path)
        }
      end

      def dimension_filter(path)
        Google::Analytics::Data::V1beta::FilterExpression.new(
          filter: Google::Analytics::Data::V1beta::Filter.new(
            field_name: 'pagePath',
            string_filter: Google::Analytics::Data::V1beta::Filter::StringFilter.new(
              match_type: :PARTIAL_REGEXP,
              value: "^#{path}(/.*)?$"
            )
          )
        )
      end

      def search_params(path, dates)
        params(path, dates).merge({ dimensions: [{ name: 'searchTerm' }],
                                    metrics: [{ name: 'eventCount' }, { name: 'sessions' },
                                              { name: 'screenPageViewsPerSession' }, { name: 'engagementRate' }],
                                    order_bys: [{ metric: { metric_name: 'eventCount' },
                                                  desc: true }] }).merge(Spotlight::Engine.config.ga_search_analytics_options)
      end

      def page_params(path, dates)
        params(path, dates).merge({
                                    dimensions: [{ name: 'pagePath' }, { name: 'pageTitle' }],
                                    order_bys: [{ metric: { metric_name: 'screenPageViews' }, desc: true }],
                                    metrics: [{ name: 'totalUsers' }, { name: 'activeUsers' },
                                              { name: 'screenPageViews' }]
                                  }).merge(Spotlight::Engine.config.ga_page_analytics_options)
      end

      def report(params)
        request = ::Google::Analytics::Data::V1beta::RunReportRequest.new(params)
        client.run_report request
      end

      def page_data(path, dates)
        metric_parsing(report(page_params(path, dates)))
      end

      def parse_data(value)
        if value.to_i.to_s == value
          value.to_i.to_fs(:delimited)
        elsif !!(value =~ /\A[-+]?\d*\.?\d+\z/)
          value.to_f
        else
          value
        end
      end

      def exhibit_data(path, dates)
        metric_parsing(report(search_params(path, dates)))
      end

      def totals
        OpenStruct.new(@report_data.totals[0].metric_values.each_with_index.with_object({}) do |(mv, index), result|
          result[metric_headers[index]] = parse_data(mv.value)
        end)
      end

      # rubocop:disable Metrics/AbcSize
      def rows
        @report_data.rows.map do |row|
          OpenStruct.new(row.dimension_values.each_with_index.with_object({}) do |(dv, index), result|
            result[dimension_headers[index]] = parse_data(dv.value)
          end.merge(row.metric_values.each_with_index.with_object({}) do |(mv, index), result|
            result[metric_headers[index]] = parse_data(mv.value)
          end))
        end
      end
      # rubocop:enable Metrics/AbcSize

      def metric_headers
        @report_data.metric_headers.map(&:name)
      end

      def dimension_headers
        @report_data.dimension_headers.map(&:name)
      end

      def metric_parsing(report_data)
        return OpenStruct.new({ totals: [], rows: [] }) unless report_data.rows.any?

        @report_data = report_data

        OpenStruct.new({ rows: rows, totals: totals })
      end

      private

      def ga_property_id
        Spotlight::Engine.config.ga_property_id
      end
    end
  end
end
