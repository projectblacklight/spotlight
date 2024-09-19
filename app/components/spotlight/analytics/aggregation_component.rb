# frozen_string_literal: true

module Spotlight
  module Analytics
    # Display Analytics aggregations as table
    class AggregationComponent < ViewComponent::Base
      def initialize(data:, exclude_fields: nil)
        super
        @exclude_fields = exclude_fields
        @data = data
      end

      def render?
        display_fields.to_h.present?
      end

      def display_fields
        return @data unless @exclude_fields

        filtered_data = @data.to_h.except(*@exclude_fields)
        OpenStruct.new(filtered_data)
      end

      def format_field(key, value)
        if value.is_a?(Float)
          if key.to_s.downcase.include?('rate')
            "#{(value * 100).to_i}%"
          else
            Kernel.format('%.2f', value)
          end
        else
          value
        end
      end
    end
  end
end
