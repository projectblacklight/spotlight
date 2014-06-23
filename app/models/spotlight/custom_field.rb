module Spotlight
  class CustomField < ActiveRecord::Base
    serialize :configuration, Hash
    belongs_to :exhibit
    
    extend FriendlyId
    friendly_id :slug_candidates, use: [:slugged,:scoped,:finders], scope: :exhibit

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
    def self.with_suffix(field)
      field.to_s + Spotlight::Engine.config.solr_fields.text_suffix
    end

    def field_name
      CustomField.with_suffix("exhibit_#{self.exhibit.to_param}_#{label.parameterize}")
    end

    def should_generate_new_friendly_id?
      true
    end  
    # Try building a slug based on the following fields in
    # increasing order of specificity.
    def slug_candidates
      [
        :label,
        :field
      ]
    end

  end
end
