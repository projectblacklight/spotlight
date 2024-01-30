# frozen_string_literal: true

module Spotlight
  ##
  # Exhibit custom fields
  class CustomField < ActiveRecord::Base
    if Rails.version > '7'
      serialize :configuration, type: Hash, coder: YAML
    else
      serialize :configuration, Hash, coder: YAML
    end
    belongs_to :exhibit, optional: true

    extend FriendlyId
    friendly_id :slug_candidates, use: %i[slugged scoped finders], scope: :exhibit

    scope :facetable, -> { where(field_type: Spotlight::Engine.config.custom_field_types.select { |_k, v| v[:facetable] }.keys) }
    scope :writeable, -> { where(readonly_field: false) }

    before_create do
      self.field ||= field_name
      self.field_type ||= 'text'
    end

    before_update :update_field_name, if: -> { field_type_changed? || readonly_field_changed? }

    after_update_commit :update_blacklight_configuration_after_field_name_change, if: -> { saved_change_to_field? || saved_change_to_slug? }
    after_update_commit :update_sidecar_data_after_field_name_change, if: -> { saved_change_to_field? || saved_change_to_slug? }

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

    def solr_field
      if field&.starts_with?(solr_field_prefix)
        # backwards compatibility with pre-0.9 custom fields
        field
      else
        "#{solr_field_prefix}#{field || field_name}"
      end
    end

    protected

    def blacklight_configuration
      exhibit&.blacklight_configuration
    end

    def update_blacklight_configuration_label(label)
      return unless field && blacklight_configuration && blacklight_configuration.index_fields.key?(field)

      blacklight_configuration.index_fields[field]['label'] = label
      blacklight_configuration.save
    end

    def field_name
      CustomFieldName.new(self).to_s
    end

    def solr_field_prefix
      document_model.solr_field_prefix(exhibit)
    end

    def view_types
      [:show] + exhibit.blacklight_configuration.blacklight_config.view.keys
    end

    def index_fields_config
      exhibit.blacklight_configuration.blacklight_config[:index_fields][field]
    end

    def should_generate_new_friendly_id?
      new_record? && slug.blank?
    end

    # Try building a slug based on the following fields in
    # increasing order of specificity.
    def slug_candidates
      %i[
        label
        field
      ]
    end

    ##
    # Rename this custom field to new_name
    # @param [String] the new name for the field
    def update_field_name
      self.field = field_name
    end

    def update_blacklight_configuration_after_field_name_change
      return unless blacklight_configuration&.index_fields&.key?(field_before_last_save)

      blacklight_configuration.index_fields_will_change!
      f = blacklight_configuration.index_fields.delete(field_before_last_save)
      blacklight_configuration.index_fields[field] = f
      blacklight_configuration.save
    end

    def update_sidecar_data_after_field_name_change
      Spotlight::RenameSidecarFieldJob.perform_later(exhibit, field_before_last_save, self.field, slug_before_last_save, slug)
    end

    def document_model
      blacklight_configuration.document_model
    end
  end
end
