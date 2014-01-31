module Spotlight
  class BlacklightConfiguration < ActiveRecord::Base
    has_many :exhibits
    serialize :facet_fields, Array
    serialize :index_fields, Hash
    serialize :show_fields, Array
    serialize :sort_fields, Array
    serialize :default_solr_params, Hash
    serialize :show, Hash
    serialize :index, Hash
    serialize :per_page, Array
    serialize :document_index_view_types, Array

    before_validation do |model|
      model.facet_fields.reject!(&:blank?) if model.facet_fields
      model.index_fields.each do |k, v| 
        v.reject!(&:blank?) 
      end if model.index_fields
      model.show_fields.reject!(&:blank?) if model.show_fields
      model.sort_fields.reject!(&:blank?) if model.sort_fields
      model.per_page.reject!(&:blank?) if model.per_page
      model.document_index_view_types.reject!(&:blank?) if model.document_index_view_types
    end

    def blacklight_config view = nil
      @blacklight_config ||= begin
        config = default_blacklight_config.inheritable_copy

        config.index_fields = config.index_fields.slice *index_fields_for_view(view) unless index_fields_for_view(view).blank?
        config.facet_fields = config.facet_fields.slice *facet_fields unless facet_fields.blank?
        config.show_fields = config.show_fields.slice *show_fields unless show_fields.blank?
        config.sort_fields = config.sort_fields.slice *sort_fields unless sort_fields.blank?
        config.per_page = per_page unless per_page.blank?
        config.document_index_view_types = document_index_view_types unless document_index_view_types.blank?

        config
      end 
    end

    def index_fields_for_view view
      index_fields.fetch(view, index_fields[:list])
    end

    def default_blacklight_config
      ::CatalogController.blacklight_config
    end

  end
end
