module Spotlight
  class Resource < ActiveRecord::Base
    include Spotlight::SolrDocument::AtomicUpdates
    class_attribute :providers
    class_attribute :weight

    belongs_to :exhibit
    serialize :data, Hash
    attr_accessor :performing_reindex

    after_save if: :data_changed? do
      unless performing_reindex
        performing_reindex = true
        reindex
        performing_reindex = false
        update_index_time!
      end
    end

    def self.providers
      Spotlight::Engine.config.resource_providers
    end

    def self.class_for_resource r
      p = providers.select do |p|
        p.can_provide? r
      end

      p.sort_by(&:weight).first
    end

    def to_solr
      {
        spotlight_resource_id_ssim: "#{(type.tableize if type) || self.class.to_s.tableize }:#{id}",
        spotlight_resource_url_ssim: url
      }
    end

    def update_index_time!
      self.update_columns indexed_at: Time.current
    end

    def becomes_provider
      klass = Spotlight::Resource.class_for_resource(self)

      if klass
        z = self.becomes klass
        z.type = z.class.to_s
        z
      else
        self
      end
    end

    def needs_provider?
      type.blank?
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
