module Spotlight
  module ArLight
    extend ActiveSupport::Concern
    include ActiveRecord::ModelSchema
    include ActiveRecord::Inheritance
    include ActiveRecord::Associations
    include ActiveRecord::Reflection
    include ActiveModel::Dirty
    included do
      def self.base_class
        self
      end
    end
    def initialize (source_doc={}, solr_response=nil)
      @association_cache = {}
      super
    end
      
    module ClassMethods
      def generated_feature_methods
        @generated_feature_methods ||= begin
          mod = const_set(:GeneratedFeatureMethods, Module.new)
          include mod
          mod
        end
      end

      def before_destroy *args
      end

      def pluralize_table_names
        true
      end

      def add_autosave_association_callbacks arg
      end

    end
  end
end
