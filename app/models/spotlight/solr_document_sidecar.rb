module Spotlight
  class SolrDocumentSidecar < ActiveRecord::Base
    belongs_to :exhibit
    belongs_to :solr_document
    serialize :data, Hash

    delegate :has_key?, to: :data

    def to_solr
      { id: solr_document_id }.merge(Hash[data.map { |k,v| ["#{k}_tesim",v] }])
    end
  end
end
