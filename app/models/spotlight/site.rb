# frozen_string_literal: true

module Spotlight
  ##
  # Global spotlight configuration
  class Site < ActiveRecord::Base
    has_many :exhibits, -> { ordered_by_weight }
    has_many :roles, as: :resource

    belongs_to :masthead, dependent: :destroy, optional: true

    accepts_nested_attributes_for :masthead, update_only: true
    accepts_nested_attributes_for :exhibits

    def self.instance
      first || create
    end
  end
end
