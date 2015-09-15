module Spotlight
  ##
  # Exhibit custom fields
  class CustomField < ActiveRecord::Base
    serialize :configuration, Hash
    belongs_to :exhibit

    extend FriendlyId
    friendly_id :slug_candidates, use: [:slugged, :scoped, :finders], scope: :exhibit

    scope :vocab, -> { where(field_type: 'vocab') }

    before_save do
      self.field ||= field_name
      self.field_type ||= 'text'
    end

    before_save do
      if persisted? && field_type_changed?
        old_field = self.field
        self.field = field_name

        if blacklight_configuration && blacklight_configuration.index_fields.key?(old_field)
          blacklight_configuration.index_fields_will_change!
          f = blacklight_configuration.index_fields.delete(old_field)
          blacklight_configuration.index_fields[field] = f
          blacklight_configuration.save
        end

        Spotlight::RenameSidecarFieldJob.perform_later(exhibit, old_field, self.field)
      end
    end

    def label=(label)
      configuration['label'] = label

      update_blacklight_configuration_label label
    end

    def label
      conf = if field && blacklight_configuration && blacklight_configuration.index_fields.key?(field)
               blacklight_configuration.index_fields[field].reverse_merge(configuration)
             else
               configuration
             end
      conf['label']
    end

    def short_description=(short_description)
      configuration['short_description'] = short_description
    end

    def short_description
      configuration['short_description']
    end

    def configured_to_display?
      index_fields_config &&
        index_fields_config['enabled'] &&
        view_types.any? do |view|
          index_fields_config[view.to_s]
        end
    end

    protected

    def blacklight_configuration
      exhibit.blacklight_configuration if exhibit
    end

    def update_blacklight_configuration_label(label)
      return unless field && blacklight_configuration && blacklight_configuration.index_fields.key?(field)

      blacklight_configuration.index_fields[field]['label'] = label
      blacklight_configuration.save
    end

    def field_name
      "#{Spotlight::Engine.config.solr_fields.prefix}exhibit_#{exhibit.to_param}_#{configuration['label'].parameterize}#{field_suffix}"
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
