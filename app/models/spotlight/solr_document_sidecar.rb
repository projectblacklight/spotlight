module Spotlight
  ##
  # Exhibit-specific metadata for indexed documents
  class SolrDocumentSidecar < ActiveRecord::Base
    belongs_to :exhibit
    belongs_to :document, polymorphic: true
    serialize :data, Hash

    delegate :has_key?, :key?, to: :data

    def to_solr
      { document.class.unique_key.to_sym => document.id, visibility_field => public? }.merge(data_to_solr)
    end

    def private!
      update public: false
    end

    def public!
      update public: true
    end

    # Roll our own polymorphism because our documents are not AREL-able
    def document
      document_type.new document_type.unique_key => document_id
    end

    def document_type
      (super.constantize if defined?(super)) || default_document_type
    end

    def default_document_type
      blacklight_config.document_model
    end

    protected

    def visibility_field
      Spotlight::SolrDocument.visibility_field(exhibit)
    end

    def blacklight_config
      exhibit.blacklight_config
    end

    def data_to_solr
      data.except('configured_fields').merge(configured_fields_data_to_solr)
    end

    def configured_fields_data_to_solr
      configured_fields = data.fetch('configured_fields', {})

      upload_fields.each_with_object({}) do |field, solr_hash|
        field_name = field.field_name.to_s
        next unless configured_fields && configured_fields[field_name].present?

        solr_fields = Array(field.solr_field || field.field_name)

        solr_fields.each do |solr_field|
          solr_hash[solr_field] = configured_fields[field_name]
        end
      end
    end

    def upload_fields
      Spotlight::Resources::Upload.fields(exhibit)
    end
  end
end
