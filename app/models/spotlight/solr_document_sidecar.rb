module Spotlight
  class SolrDocumentSidecar < ActiveRecord::Base
    belongs_to :exhibit
    belongs_to :solr_document
    serialize :data, Hash

    delegate :has_key?, to: :data

    def to_solr
      { id: solr_document_id, Spotlight::SolrDocument.visibility_field(exhibit) => public? }.merge(Hash[data.map { |k,v| ["#{k}_tesim",v] }])
    end

    def private!
      update public: false
    end

    def public!
      update public: true
    end
  end
end
