# frozen_string_literal: true

module Spotlight
  # :nodoc:
  class ApplicationJob < ActiveJob::Base
    queue_as :default
  end
end
