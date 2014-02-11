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
      end
    end

    def update current_exhibit, new_attributes
      attributes = new_attributes.stringify_keys

      if custom_data = attributes.delete("sidecar")
        sidecar(current_exhibit).update(custom_data)
      end

      attributes.each do |k, v|
        if respond_to? "#{k}="
          send "#{k}=", v
        end
      end
    end

    def reindex
      #TODO implement this
    end

    def save
      save_tags
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
      @sidecar ||= SolrDocumentSidecar.find_or_initialize_by exhibit: exhibit, solr_document_id: self.id
    end
  end
end

ActsAsTaggableOn::Tagging.after_destroy do |obj|
  ::SolrDocument.reindex(obj.taggable_id)
end
