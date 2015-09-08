module Spotlight
  ##
  # Stub ActiveRecord methods to allow non-ActiveRecord::Base objects to
  # participate in e.g. associations
  module ArLight
    extend ActiveSupport::Concern
    include ActiveRecord::ModelSchema
    include ActiveRecord::Inheritance
    include ActiveRecord::Associations
    include ActiveRecord::Reflection
    include ActiveModel::Dirty

    ##
    # Mock activerecord class-level methods
    module ClassMethods
      def base_class
        self
      end

      # required for Rails >= 4.0.4
      def subclass_from_attributes?(_)
        false
      end

      def generated_feature_methods
        @generated_feature_methods ||= begin
          mod = const_set(:GeneratedFeatureMethods, Module.new)
          include mod
          mod
        end
      end

      def before_destroy(*_args)
      end

      def pluralize_table_names
        true
      end

      def add_autosave_association_callbacks(_arg)
      end

      # needed for Rails 4.1 + act_as_taggable
      def dangerous_attribute_method?(*_args)
        false
      end

      # needed for Rails 4.1 + act_as_taggable
      def generated_association_methods
        @generated_association_methods ||= begin
          mod = const_set(:GeneratedAssociationMethods, Module.new)
          include mod
          mod
        end
      end

      def validators_on(*_)
        []
      end

      def default_scopes
        []
      end
    end

    def initialize(source_doc = {}, solr_response = nil)
      @association_cache = {}
      super
    end

    # Returns true if +comparison_object+ is the same exact object, or +comparison_object+
    # is of the same type and +self+ has an ID and it is equal to +comparison_object.id+.
    #
    # Note that new records are different from any other record by definition, unless the
    # other record is the receiver itself. Besides, if you fetch existing records with
    # +select+ and leave the ID out, you're on your own, this predicate will return false.
    #
    # Note also that destroying a record preserves its ID in the model instance, so deleted
    # models are still comparable.
    def ==(other)
      super ||
        (other.instance_of?(self.class) &&
          id &&
          other.id == id)
    end
  end
end
