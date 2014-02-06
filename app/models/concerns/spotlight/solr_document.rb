module Spotlight
  module SolrDocument
    extend ActiveSupport::Concern
    included do
      include ArLight
      include ActiveModel::Dirty
      def self.base_class
        self
      end
      extend ActsAsTaggableOn::Compatibility
      extend ActsAsTaggableOn::Taggable

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
    end

    def save
      save_tags
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
  end
end
