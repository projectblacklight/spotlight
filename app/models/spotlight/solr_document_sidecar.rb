module Spotlight
  class SolrDocumentSidecar < ActiveRecord::Base
    belongs_to :exhibit
    belongs_to :solr_document
    serialize :data, Hash

    delegate :has_key?, to: :data

    def to_solr
      { id: solr_document_id }.merge(data)
    end
  end
end
