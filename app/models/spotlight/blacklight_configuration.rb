require 'blacklight/utils'

module Spotlight
  class BlacklightConfiguration < ActiveRecord::Base
    has_one :exhibit
    serialize :facet_fields, Hash
    serialize :index_fields, Hash
    serialize :show_fields, Array
    serialize :sort_fields, Array
    serialize :default_solr_params, Hash
    serialize :show, Hash
    serialize :index, Hash
    serialize :per_page, Array
    serialize :document_index_view_types, Array

    # get rid of empty values
    before_validation do |model|
      model.facet_fields.each do |k,v|
        v[:enabled] = (v[:enabled] == "1")
        v.reject! { |k, v1| v1.blank? and !v1 === false }
      end if model.facet_fields

      model.index_fields.each do |k, v|
        v.reject!(&:blank?)
      end if model.index_fields

      model.show_fields.reject!(&:blank?) if model.show_fields
      model.sort_fields.reject!(&:blank?) if model.sort_fields
      model.per_page.reject!(&:blank?) if model.per_page
      model.document_index_view_types.reject!(&:blank?) if model.document_index_view_types
    end

    ##
    # Serialize this configuration to a Blacklight::Configuration object 
    # appropriate to the current view. If a value isn't set in this record,
    # it will use the configuration set upstream (in default_blacklight_config)
    # @param [String] view the configuration may be different depending on the index view selected
    def blacklight_config view = nil
      config = default_blacklight_config.inheritable_copy

      config.show.merge! show unless show.blank?
      config.index.merge! index unless index.blank?

      config.default_solr_params = config.default_solr_params.merge(default_solr_params)

      config.index_fields = config.index_fields.slice *index_fields_for_view(view) unless index_fields_for_view(view).blank?
      config.show_fields = config.show_fields.slice *show_fields unless show_fields.blank?
      config.sort_fields = config.sort_fields.slice *sort_fields unless sort_fields.blank?
      
      unless facet_fields.blank?
        active_facet_fields = facet_fields.select { |k,v| v[:enabled] == true }
        config.facet_fields.slice! *active_facet_fields.keys
        config.facet_fields = Hash[config.facet_fields.sort_by { |k,v| active_facet_fields.keys.index k }]
        
        config.facet_fields.each do |k, v|
          next if facet_fields[k].blank?

          v.merge! facet_fields[k].symbolize_keys
          v.normalize! config
          v.validate!
        end
      end

      config.per_page = (config.per_page & per_page) unless per_page.blank?
      config.view.select! { |k, v| document_index_view_types.include? k.to_s } unless document_index_view_types.blank?

      config
    end

    def all_facet_fields
      default_blacklight_config.facet_fields.sort_by { |k,v| facet_fields.keys.index k }


    end

    ##
    # Get the index fields that should be visible for the given view; if the view is
    # not found, just use the list view.
    # @param [String] view 
    def index_fields_for_view view
      index_fields.fetch(view, index_fields[:list])
    end

    ##
    # Get the "upstream" blacklight configuration to use
    def default_blacklight_config
      ::CatalogController.blacklight_config
    end

  end
end
