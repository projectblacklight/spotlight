module Spotlight
  class SolrDocumentSidecar < ActiveRecord::Base
    belongs_to :exhibit
    belongs_to :solr_document
    serialize :data, Hash

    delegate :has_key?, to: :data
  end
end
