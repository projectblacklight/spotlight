module Spotlight
  ##
  # SolrDocument mixins to add ActiveModel shims and indexing methods
  module SolrDocument
    extend ActiveSupport::Concern

    include Spotlight::SolrDocument::ActiveModelConcern
    include Spotlight::SolrDocument::Finder
    include Spotlight::SolrDocument::SpotlightImages
    include GlobalID::Identification

    included do
      extend ActsAsTaggableOn::Compatibility
      extend ActsAsTaggableOn::Taggable

      acts_as_taggable
      has_many :sidecars, class_name: 'Spotlight::SolrDocumentSidecar', as: :document

      before_save :save_owned_tags
      after_save :reindex

      use_extension(Spotlight::SolrDocument::UploadedResource, &:uploaded_resource?)
    end

    ##
    # Class-level methods
    module ClassMethods
      def reindex(id)
        find(id).reindex
      rescue Blacklight::Exceptions::InvalidSolrID => e
        Rails.logger.debug "Unable to find document #{id}: #{e}"
      end
    end

    def update(current_exhibit, new_attributes)
      attributes = new_attributes.stringify_keys

      custom_data = attributes.delete('sidecar')
      tags = attributes.delete('exhibit_tag_list')
      resource_attributes = attributes.delete('uploaded_resource')

      sidecar(current_exhibit).update(custom_data) if custom_data

      # Note: this causes a save
      current_exhibit.tag(self, with: tags, on: :tags) if tags

      update_exhibit_resource(resource_attributes) if uploaded_resource?
    end

    def update_exhibit_resource(resource_attributes)
      return unless resource_attributes && resource_attributes['url']
      uploaded_resource.update url: resource_attributes['url']
    end

    def reindex
      # no-op reindex implementation
    end

    def sidecar(exhibit)
      sidecars.find_or_initialize_by exhibit: exhibit
    end

    def to_solr
      { self.class.unique_key.to_sym => id }.reverse_merge(sidecars.inject({}) { |a, e| a.merge(e.to_solr) }).merge(tags_to_solr)
    end

    # rubocop:disable Metrics/LineLength
    def self.solr_field_for_tagger(tagger)
      :"#{Spotlight::Engine.config.solr_fields.prefix}#{tagger.class.model_name.param_key}_#{tagger.id}_tags#{Spotlight::Engine.config.solr_fields.string_suffix}"
    end

    def self.visibility_field(exhibit)
      :"#{Spotlight::Engine.config.solr_fields.prefix}#{exhibit.class.model_name.param_key}_#{exhibit.id}_public#{Spotlight::Engine.config.solr_fields.boolean_suffix}"
    end
    # rubocop:enable Metrics/LineLength

    def self.resource_type_field
      :"#{Spotlight::Engine.config.solr_fields.prefix}spotlight_resource_type#{Spotlight::Engine.config.solr_fields.string_suffix}"
    end

    def make_public!(exhibit)
      sidecar(exhibit).public!
    end

    def make_private!(exhibit)
      sidecar(exhibit).private!
    end

    def private?(exhibit)
      !(public?(exhibit))
    end

    def public?(exhibit)
      sidecar(exhibit).public?
    end

    def uploaded_resource?
      self[Spotlight::SolrDocument.resource_type_field].present? &&
        self[Spotlight::SolrDocument.resource_type_field].include?('spotlight/resources/uploads')
    end

    def attribute_present?(*_args)
      false
    end

    protected

    def tags_to_solr
      h = {}

      # Adding a placeholder entry in case the last tag for an exhibit
      # is removed, so we clear out the solr field too.
      Spotlight::Exhibit.find_each do |exhibit|
        h[Spotlight::SolrDocument.solr_field_for_tagger(exhibit)] = nil
      end

      taggings.includes(:tag, :tagger).map do |tagging|
        key = Spotlight::SolrDocument.solr_field_for_tagger(tagging.tagger)
        h[key] ||= []
        h[key] << tagging.tag.name
      end
      h
    end
  end
end

ActsAsTaggableOn::Tagging.after_destroy do |obj|
  if obj.tagger.is_a? Spotlight::Exhibit
    obj.tagger.blacklight_config.document_model.reindex(obj.taggable_id)
  end
end
