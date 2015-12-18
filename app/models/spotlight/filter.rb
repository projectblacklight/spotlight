module Spotlight
  # A configurable solr filter for the exhibit
  class Filter < ActiveRecord::Base
    belongs_to :exhibit

    validates :field, :value, presence: true

    def to_hash
      return {} unless field

      { field => cast_value }
    end

    private

    def cast_value
      return value unless field

      if field.ends_with? Spotlight::Engine.config.solr_fields.boolean_suffix
        ActiveRecord::Type::Boolean.new.type_cast_from_database(value)
      else
        value
      end
    end
  end
end
