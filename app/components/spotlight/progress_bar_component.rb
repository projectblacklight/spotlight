# frozen_string_literal: true

module Spotlight
  # Renders progress bar html which is updated by progress_monitor.js
  class ProgressBarComponent < ViewComponent::Base
    attr_reader :exhibit, :translation_field

    def initialize(exhibit:, translation_field:)
      @exhibit = exhibit
      @translation_field = translation_field
      super
    end
  end
end