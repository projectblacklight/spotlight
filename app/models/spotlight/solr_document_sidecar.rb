# frozen_string_literal: true

module Spotlight
  ##
  # Exhibit-specific metadata for indexed documents
  class SolrDocumentSidecar < ActiveRecord::Base
    extend ActsAsTaggableOn::Taggable

    acts_as_taggable

    belongs_to :exhibit, optional: false
    belongs_to :resource, optional: true
    belongs_to :document, optional: false, polymorphic: true

    if Rails.version > '7.1'
      serialize :data, type: Hash, coder: YAML
      serialize :index_status, type: Hash, coder: YAML
    else
      serialize :data, Hash, coder: YAML
      serialize :index_status, Hash, coder: YAML
    end

    delegate :has_key?, :key?, to: :data

    def to_solr
      { document.class.unique_key.to_sym => document.id,
        visibility_field => public? }
        .merge(data_to_solr)
        .merge(exhibit.solr_data)
    end

    def private!
      update public: false
    end

    def public!
      update public: true
    end

    # Roll our own polymorphism because our documents are not AREL-able
    def document
      document_type_class.new document_type_class.unique_key => document_id
    end

    def default_document_type
      blacklight_config.document_model
    end

    private

    def document_type_class
      return default_document_type unless document_type.is_a?(String)

      document_type.constantize
    end

    def visibility_field
      blacklight_config.document_model.visibility_field(exhibit)
    end

    def blacklight_config
      exhibit.blacklight_config
    end

    def data_to_solr
      custom_fields_data_to_solr.merge(configured_fields_data_to_solr)
    end

    def custom_fields_data_to_solr
      data.except('configured_fields').each_with_object({}) do |(key, value), solr_hash|
        custom_field = custom_fields[key]
        field_name = custom_field.solr_field if custom_field
        field_name ||= key
        solr_hash[field_name] = convert_stored_value_to_solr(value)
      end
    end

    def configured_fields_data_to_solr
      configured_fields = data.fetch('configured_fields', {})

      upload_fields.each_with_object({}) do |field, solr_hash|
        field_name = field.field_name.to_s

        value = configured_fields[field_name]
        field_data = field.data_to_solr(convert_stored_value_to_solr(value))

        # merge duplicate field mappings into a multivalued field
        solr_hash.merge!(field_data) { |_key, v1, v2| (Array(v1) + Array(v2)).reject(&:blank?) }
      end
    end

    def upload_fields
      return [] unless document.uploaded_resource? || resource.is_a?(Spotlight::Resources::Upload)

      Spotlight::Resources::Upload.fields(exhibit)
    end

    def custom_fields
      exhibit.custom_fields.each_with_object({}) do |custom_field, hash|
        hash[custom_field.slug] = custom_field

        # for backwards compatibility
        hash[custom_field.field] = custom_field
      end
    end

    def convert_stored_value_to_solr(value)
      if value.blank?
        nil
      elsif value.is_a? Array
        value.reject(&:blank?)
      elsif value.is_a? Hash
        value.values.reject(&:blank?)
      else
        value
      end
    end
  end
end
