module Spotlight::SolrDocument::ActiveModelConcern
  extend ActiveSupport::Concern
  
  included do
    include Spotlight::ArLight
    extend ActiveModel::Callbacks
    define_model_callbacks :save
  end
  
  module ClassMethods

    # needed for Rails 4.1 + act_as_taggable
    def dangerous_attribute_method? *args
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
  end
  
  def save
    run_callbacks :save do
      # no-op
    end
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
