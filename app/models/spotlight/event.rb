# frozen_string_literal: true

module Spotlight
  # Logged events for Spotlight exhibits
  class Event < ActiveRecord::Base
    belongs_to :resource, polymorphic: true
    belongs_to :exhibit, optional: true

    serialize :data, coder: YAML

    self.inheritance_column = :event_class
  end
end
