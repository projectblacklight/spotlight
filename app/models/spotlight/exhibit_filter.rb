module Spotlight
  # A configurable solr filter for the exhibit
  class ExhibitFilter < ActiveRecord::Base
    belongs_to :exhibit

    validates :field, :value, presence: true
  end
end
