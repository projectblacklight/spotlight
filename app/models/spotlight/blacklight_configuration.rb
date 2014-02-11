require 'blacklight/utils'

module Spotlight
  class BlacklightConfiguration < ActiveRecord::Base
    has_one :exhibit
    serialize :facet_fields, Hash
    serialize :index_fields, Hash
    serialize :sort_fields, Hash
    serialize :default_solr_params, Hash
    serialize :show, Hash
    serialize :index, Hash
    serialize :per_page, Array
    serialize :document_index_view_types, Array

    # get rid of empty values
    before_validation do |model|

      model.index_fields.each do |k,v|
        v[:enabled] ||= v.any? { |k1, v1| !v1.blank? }

        default_blacklight_config.view.keys.each do |view|
          v[view] &&= (v[view] == "1")
        end

        v[:show] &&= (v[:show] == "1")

        v.reject! { |k, v1| v1.blank? and !v1 === false }
      end if model.index_fields

      [:facet_fields, :sort_fields].each do |field|
        model.send(field).each do |k,v|
          v[:enabled] &&= (v[:enabled] == "1")
          v[:enabled] ||= true if v[:enabled].nil?
          v.reject! { |k, v1| v1.blank? and !v1 === false }
        end if model.send(field)
      end

      model.per_page.reject!(&:blank?) if model.per_page
      model.document_index_view_types.reject!(&:blank?) if model.document_index_view_types
    end

    ##
    # Serialize this configuration to a Blacklight::Configuration object 
    # appropriate to the current view. If a value isn't set in this record,
    # it will use the configuration set upstream (in default_blacklight_config)
    # @param [String] view the configuration may be different depending on the index view selected
    def blacklight_config view = :list
      config = default_blacklight_config.inheritable_copy

      config.show.merge! show unless show.blank?
      config.index.merge! index unless index.blank?

      config.default_solr_params = config.default_solr_params.merge(default_solr_params)


      config.show.partials.unshift "spotlight/catalog/curation_mode_toggle"
      
      show_fields = index_fields_for_view(:show)
      unless show_fields.blank?
        active_show_fields = show_fields.select { |k,v| v[:enabled] == true }
        config.show_fields = config.index_fields.slice *active_show_fields.keys
        config.show_fields = Hash[config.show_fields.sort_by { |k,v| field_weight(active_show_fields, k)}]

        config.index_fields.each do |k, v|
          next if show_fields[k].blank?

          v.merge! show_fields[k].symbolize_keys
          v.normalize! config
          v.validate!
        end
      end

      unless index_fields_for_view(view).blank?
        active_index_fields = index_fields_for_view(view).select { |k,v| v[:enabled] == true }
        config.index_fields.slice! *active_index_fields.keys
        config.index_fields = Hash[config.index_fields.sort_by { |k,v| field_weight(active_index_fields, k) }]

        config.index_fields.each do |k, v|
          next if index_fields[k].blank?

          v.merge! index_fields[k].symbolize_keys
          v.normalize! config
          v.validate!
        end
      end

      unless sort_fields.blank?
        active_sort_fields = sort_fields.select { |k,v| v[:enabled] == true }
        config.sort_fields.slice! *active_sort_fields.keys
        config.sort_fields = Hash[config.sort_fields.sort_by { |k,v| field_weight(active_sort_fields, k) }]

        config.sort_fields.each do |k, v|
          next if sort_fields[k].blank?

          v.merge! sort_fields[k].symbolize_keys
          v.normalize! config
          v.validate!
        end
      end

      unless facet_fields.blank?
        active_facet_fields = facet_fields.select { |k,v| v[:enabled] == true }
        config.facet_fields.slice! *active_facet_fields.keys
        config.facet_fields = Hash[config.facet_fields.sort_by { |k,v| field_weight(active_facet_fields, k) }]

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
      Hash[default_blacklight_config.facet_fields.sort_by { |k,v| field_weight(facet_fields, k) }]
    end

    def all_index_fields
      Hash[default_blacklight_config.index_fields.sort_by { |k,v| field_weight(index_fields, k) }]
    end

    ##
    # Get the index fields that should be visible for the given view; if the view is
    # not found, just use the list view.
    # @param [String] view 
    def index_fields_for_view view = :list
      index_fields.select do |key, config|
        config.with_indifferent_access[:enabled] &&
          config.with_indifferent_access[view]
      end
    end

    ##
    # Get the "upstream" blacklight configuration to use
    def default_blacklight_config
      ::CatalogController.blacklight_config
    end

    protected

    def field_weight fields, index
      fields.fetch(index, {})[:weight] || (100 + (fields.keys.index(index) || fields.keys.length))
    end
  end
end
