module Spotlight
  ##
  # Global spotlight configuration
  class Site < ActiveRecord::Base
    has_many :exhibits
    has_many :roles, as: :resource

    belongs_to :masthead, dependent: :destroy

    accepts_nested_attributes_for :masthead, :exhibits

    def self.instance
      first || create
    end
  end
end
