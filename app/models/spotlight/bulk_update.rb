# frozen_string_literal: true

module Spotlight
  class BulkUpdate < ActiveRecord::Base
    has_one_attached :file
    belongs_to :exhibit
  end
end
