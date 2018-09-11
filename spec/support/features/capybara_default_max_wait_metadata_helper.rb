module CapybaraDefaultMaxWaitMetadataHelper
  extend ActiveSupport::Concern

  included do
    before do |example|
      next unless example.metadata[:default_max_wait_time]

      @previous_wait_time = Capybara.default_max_wait_time
      Capybara.default_max_wait_time = example.metadata[:default_max_wait_time]
    end

    after do |example|
      next unless example.metadata[:default_max_wait_time]

      Capybara.default_max_wait_time = @previous_wait_time
    end
  end
end
