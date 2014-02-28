module Spotlight
  class Resource < ActiveRecord::Base
    include Spotlight::SolrDocument::AtomicUpdates
    belongs_to :exhibit
    serialize :data, Hash

    after_save if: :data_changed? do
      reindex
      update_index_time!
    end

    def to_solr
      {}
    end

    def update_index_time!
      self.update_columns indexed_at: Time.current
    end

    protected

    def blacklight_solr
      @solr ||=  RSolr.connect(blacklight_solr_config)
    end

    def blacklight_solr_config
      Blacklight.solr_config
    end
  end
end