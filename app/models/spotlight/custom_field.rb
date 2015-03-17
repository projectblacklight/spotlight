module Spotlight
  class CustomField < ActiveRecord::Base
    serialize :configuration, Hash
    belongs_to :exhibit
    
    extend FriendlyId
    friendly_id :slug_candidates, use: [:slugged,:scoped,:finders], scope: :exhibit
    
    scope :vocab, -> { where(field_type: "vocab") }

    before_save do
      self.field ||= field_name
      self.field_type ||= "text"
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

    def configured_to_display?
      if index_fields_config && index_fields_config["enabled"]
        view_types.any? do |view|
          index_fields_config[view.to_s]
        end
      end
    end

    protected
    def field_name
      "#{Spotlight::Engine.config.solr_fields.prefix}exhibit_#{self.exhibit.to_param}_#{label.parameterize}#{field_suffix}"
    end

    def field_suffix
      case field_type
      when 'vocab'
        Spotlight::Engine.config.solr_fields.string_suffix
      else
        Spotlight::Engine.config.solr_fields.text_suffix    
      end
    end

    def view_types
      [:show] + exhibit.blacklight_configuration.blacklight_config.view.keys
    end

    def index_fields_config
      exhibit.blacklight_configuration.blacklight_config[:index_fields][field]
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
