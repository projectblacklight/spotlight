# frozen_string_literal: true

module Spotlight
  # Logged events for Spotlight exhibits
  class Event < ActiveRecord::Base
    belongs_to :resource, polymorphic: true
    belongs_to :exhibit

    serialize :data

    self.inheritance_column = :event_class
  end
end
