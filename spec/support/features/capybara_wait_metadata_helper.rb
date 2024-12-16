# frozen_string_literal: true

module CapybaraWaitMetadataHelper
  extend ActiveSupport::Concern

  included do
    around do |example|
      using_wait_time example.metadata[:max_wait_time] || Capybara.default_max_wait_time do
        example.run
      end
    end
  end
end
