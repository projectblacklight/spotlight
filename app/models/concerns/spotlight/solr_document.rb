module Spotlight
  module SolrDocument
    extend ActiveSupport::Concern
    included do
      include ArLight
      extend ActsAsTaggableOn::Compatibility
      extend ActsAsTaggableOn::Taggable
      include Blacklight::SolrHelper
      extend Finder

      acts_as_taggable
      has_many :sidecars, class_name: 'Spotlight::SolrDocumentSidecar'
    end

    module ClassMethods

      # stub this out for acts_as_taggable_on
      def after_save *args
        #nop
      end

      def primary_key
        :id
      end

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

    def save
      save_owned_tags
      reindex
    end

    def to_key
      [id]
    end

    def persisted?
      true
    end

    def destroyed?
      false
    end

    def new_record?
      !persisted?
    end

    def sidecar exhibit
      sidecars.first_or_initialize(exhibit: exhibit)
    end

    def to_solr
      { id: id }.reverse_merge(sidecars.inject({}) { |result, sidecar| result.merge(sidecar.to_solr) }).merge(tags_to_solr)
    end

    def self.solr_field_for_tagger tagger
      :"#{tagger.class.model_name.param_key}_#{tagger.id}_tags_ssim"
    end

    def self.visibility_field exhibit
      :"#{exhibit.class.model_name.param_key}_#{exhibit.id}_public_bsi"
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
  ::SolrDocument.reindex(obj.taggable_id)
end
