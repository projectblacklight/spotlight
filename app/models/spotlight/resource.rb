module Spotlight
  class Resource < ActiveRecord::Base
    include Spotlight::SolrDocument::AtomicUpdates
    extend ActiveModel::Callbacks
    define_model_callbacks :index

    class_attribute :providers
    class_attribute :weight

    belongs_to :exhibit
    serialize :data, Hash

    after_save :reindex

    around_index :reindex_with_lock

    after_index :update_index_time!

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
      exhibit.solr_data.merge({
        :"#{Spotlight::Engine.config.solr_fields.prefix}spotlight_resource_id#{Spotlight::Engine.config.solr_fields.string_suffix}" => "#{(type.tableize if type) || self.class.to_s.tableize }:#{id}",
        :"#{Spotlight::Engine.config.solr_fields.prefix}spotlight_resource_url#{Spotlight::Engine.config.solr_fields.string_suffix}" => url,
        Spotlight::SolrDocument.resource_type_field => self.class.to_s.tableize
      })
    end
    
    def reindex_with_lock
      with_lock do
        yield
      end
    end
    
    def reindex
      run_callbacks :index do
        data = to_solr
        data = [data] unless data.is_a? Array
        blacklight_solr.update params: { commitWithin: 500 }, data: data.to_json, headers: { 'Content-Type' => 'application/json'} unless data.empty?
      end
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
    
    def solr_document_model
      exhibit.blacklight_config.solr_document_model
    end
  end
end
