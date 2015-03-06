module Spotlight
  class SolrDocumentSidecar < ActiveRecord::Base
    belongs_to :exhibit
    belongs_to :document, polymorphic: true
    serialize :data, Hash

    delegate :has_key?, to: :data

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
      data.except("configured_fields").merge(configured_fields_data_to_solr)
    end

    def configured_fields_data_to_solr
      solr_hash = {}
      if data["configured_fields"]
        configured_fields = Spotlight::Resources::Upload.fields(exhibit)

        configured_fields.each do |field|
          solr_fields = Array(field.solr_field || field.field_name)
          if data["configured_fields"][field.field_name.to_s].present?
            solr_fields.each do |solr_field|
              solr_hash[solr_field] = data["configured_fields"][field.field_name.to_s]
            end
          end
        end
      end

      solr_hash.select { |k,v| v.present? }
    end

  end
end
