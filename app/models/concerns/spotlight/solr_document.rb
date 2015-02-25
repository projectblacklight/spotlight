module Spotlight
  module SolrDocument
    extend ActiveSupport::Concern
    
    include Blacklight::SolrHelper
    include Spotlight::SolrDocument::ActiveModelConcern
    include Spotlight::SolrDocument::Finder
    include GlobalID::Identification

    included do
      extend ActsAsTaggableOn::Compatibility
      extend ActsAsTaggableOn::Taggable

      acts_as_taggable
      has_many :sidecars, class_name: 'Spotlight::SolrDocumentSidecar', as: :document
      
      before_save :save_owned_tags
      after_save :reindex

      use_extension(Spotlight::SolrDocument::UploadedResource) do |document|
        document.uploaded_resource?
      end
    end
    
    module ClassMethods  
      def reindex(id)
        find(id).reindex
      rescue Blacklight::Exceptions::InvalidSolrID
        # no-op
      end
    end

    def update current_exhibit, new_attributes
      attributes = new_attributes.stringify_keys

      if custom_data = attributes.delete("sidecar")
        sidecar(current_exhibit).update(custom_data)
      end

      if tags = attributes.delete("exhibit_tag_list")
        # Note: this causes a save
        current_exhibit.tag(self, with: tags, on: :tags)
      end
    end

    def reindex
      # no-op reindex implementation
    end

    def sidecar exhibit
      sidecars.find_or_initialize_by exhibit: exhibit
    end

    def to_solr
      { self.class.unique_key.to_sym => id }.reverse_merge(sidecars.inject({}) { |result, sidecar| result.merge(sidecar.to_solr) }).merge(tags_to_solr)
    end

    def self.solr_field_for_tagger tagger
      ("#{Spotlight::Engine.config.solr_fields.prefix}#{tagger.class.model_name.param_key}_#{tagger.id}_tags" + Spotlight::Engine.config.solr_fields.string_suffix).to_sym
    end

    def self.visibility_field exhibit
      ("#{Spotlight::Engine.config.solr_fields.prefix}#{exhibit.class.model_name.param_key}_#{exhibit.id}_public" + Spotlight::Engine.config.solr_fields.boolean_suffix).to_sym
    end
    
    def self.resource_type_field
      :"#{Spotlight::Engine.config.solr_fields.prefix}spotlight_resource_type#{Spotlight::Engine.config.solr_fields.string_suffix}"
    end

    def make_public! exhibit
      sidecar(exhibit).public!
    end

    def make_private! exhibit
      sidecar(exhibit).private!
    end

    def private? exhibit
      !(public?(exhibit))
    end

    def public? exhibit
      sidecar(exhibit).public?
    end

    def uploaded_resource?
      self[Spotlight::Engine.config.full_image_field].present? &&
      self[Spotlight::SolrDocument.resource_type_field].present? &&
      self[Spotlight::SolrDocument.resource_type_field].include?("spotlight/resources/uploads")
    end

    def attribute_present? *args
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
    obj.tagger.blacklight_config.solr_document_model.reindex(obj.taggable_id)
  end
end
