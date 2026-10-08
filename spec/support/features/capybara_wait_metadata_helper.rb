# frozen_string_literal: true

module CapybaraWaitMetadataHelper
  extend ActiveSupport::Concern

  included do
    around do |example|
      next example.run unless example.metadata.key?(:max_wait_time)

      using_wait_time example.metadata[:max_wait_time] do
        example.run
      end
    end
  end
end
