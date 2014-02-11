module Spotlight
  class CustomField < ActiveRecord::Base
    serialize :configuration, Hash
    belongs_to :exhibit

    before_save do
      self.field ||= field_name
    end

    private
    def field_name
      "exhibit_#{self.exhibit.to_param}_#{label.parameterize}"
    end

  end
end
