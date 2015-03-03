module Spotlight
  class SolrDocumentSidecar < ActiveRecord::Base
    belongs_to :exhibit, class_name: 'Spotlight::Exhibit'
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
      blacklight_config.solr_document_model
    end

    protected

    def visibility_field
      Spotlight::SolrDocument.visibility_field(exhibit)
    end

    def blacklight_config
      exhibit.blacklight_config
    end

    def data_to_solr
      Hash[data.map { |k,v| [k,v] }]
    end
  end
end
