module Spotlight
  class CustomField < ActiveRecord::Base
    serialize :configuration, Hash
    belongs_to :exhibit

    before_save do
      self.field ||= field_name
    end

    def label=(label)
      configuration["label"] = label
      if (field && exhibit)
        conf = exhibit.blacklight_configuration
        conf.index_fields.fetch(field, configuration)['label'] = label
        conf.save!
      end
    end

    def label
      return configuration["label"] unless (field && exhibit)
      exhibit.blacklight_configuration.index_fields.fetch(field, configuration)['label']
    end

    def short_description=(short_description)
      configuration["short_description"] = short_description
    end

    def short_description
      configuration["short_description"]
    end
    
    protected 
    SUFFIX = '_tesim'.freeze
    def self.with_suffix(field)
      field.to_s + SUFFIX
    end

    private
    def field_name
      CustomField.with_suffix("exhibit_#{self.exhibit.to_param}_#{label.parameterize}")
    end

  end
end
