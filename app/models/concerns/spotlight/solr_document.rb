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

    def update new_attributes
      attributes = new_attributes.stringify_keys

      attributes.each do |k, v|
        send "#{k}=", v
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

    def exhibit_specific_field exhibit, field
      nil
    end
  end
end

ActsAsTaggableOn::Tagging.after_destroy do |obj|
  ::SolrDocument.reindex(obj.taggable_id)
end
