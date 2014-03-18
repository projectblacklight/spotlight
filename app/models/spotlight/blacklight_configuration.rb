require 'blacklight/utils'

module Spotlight
  class BlacklightConfiguration < ActiveRecord::Base
    belongs_to :exhibit
    serialize :facet_fields, Hash
    serialize :index_fields, Hash
    serialize :sort_fields, Hash
    serialize :default_solr_params, Hash
    serialize :show, Hash
    serialize :index, Hash
    serialize :per_page, Array
    serialize :document_index_view_types, Array

    include Spotlight::BlacklightConfigurationDefaults

    # get rid of empty values
    before_validation do |model|

      model.index_fields.each do |k,v|
        v[:enabled] ||= v.any? { |k1, v1| !v1.blank? }

        default_blacklight_config.view.keys.each do |view|
          v[view] &&= ActiveRecord::ConnectionAdapters::Column.value_to_boolean(v[view])
        end

        v[:show] &&= ActiveRecord::ConnectionAdapters::Column.value_to_boolean(v[:show])

        v.reject! { |k, v1| v1.blank? and !v1 === false }
      end if model.index_fields

      model.facet_fields.each do |k,v|
        v[:show] &&= ActiveRecord::ConnectionAdapters::Column.value_to_boolean(v[:show])
        v[:show] ||= true if v[:show].nil?
        v.reject! { |k, v1| v1.blank? and !v1 === false }
      end if model.facet_fields

      model.sort_fields.each do |k,v|
        v[:enabled] &&= ActiveRecord::ConnectionAdapters::Column.value_to_boolean(v[:enabled])
        v[:enabled] ||= true if v[:enabled].nil?
        v.reject! { |k, v1| v1.blank? and !v1 === false }
      end if model.sort_fields

      model.per_page.reject!(&:blank?) if model.per_page
      model.document_index_view_types.reject!(&:blank?) if model.document_index_view_types
    end

    ##
    # Serialize this configuration to a Blacklight::Configuration object 
    # appropriate to the current view. If a value isn't set in this record,
    # it will use the configuration set upstream (in default_blacklight_config)
    # @param [String] view the configuration may be different depending on the index view selected
    def blacklight_config
      @blacklight_config ||= begin
        # Create a new config based on the defaults
        config = default_blacklight_config.inheritable_copy

        config.show.merge! show unless show.blank?
        config.index.merge! index unless index.blank?

        config.default_autocomplete_solr_params[:fl] = "id #{config.index.title_field} #{config.index.thumbnail_field}"

        config.default_solr_params = config.default_solr_params.merge(default_solr_params)

        config.show.partials.insert(2, "spotlight/catalog/tags")

        # Add any custom fields
        config.index_fields.merge! custom_index_fields
        config.index_fields = Hash[config.index_fields.sort_by { |k,v| field_weight(index_fields, k) }]

        # Update with customizations
        config.index_fields.each do |k, v|
          if index_fields[k].blank?
            set_index_field_defaults(v)
          else
            v.merge! index_fields[k].symbolize_keys
          end

          v.normalize! config
          v.validate!
        end
        
        config.show_fields = config.index_fields

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
          config.facet_fields = Hash[config.facet_fields.sort_by { |k,v| field_weight(facet_fields, k) }]

          config.facet_fields.each do |k, v|
            next if facet_fields[k].blank?

            v.merge! facet_fields[k].symbolize_keys
            v.normalize! config
            v.validate!
          end
        end

        config.per_page = (config.per_page & per_page) unless per_page.blank?
        
        if default_per_page
          config.per_page.delete(default_per_page)
          config.per_page.unshift(default_per_page)
        end

        config.view.select! { |k, v| document_index_view_types.include? k.to_s } unless document_index_view_types.blank?

        config
      end
    end

    def custom_index_fields
      Hash[exhibit.custom_fields.map do |x| 
        field = Blacklight::Configuration::IndexField.new x.configuration.merge(field: x.field)
        [x.field, field] 
      end]
    end

    ##
    # Get the "upstream" blacklight configuration to use
    def default_blacklight_config
      @default_blacklight_config ||= begin
        config = ::CatalogController.blacklight_config.deep_copy
        config.add_facet_field Spotlight::SolrDocument.solr_field_for_tagger(exhibit), label: "Exhibit Tags", show: false
        config
      end
    end

    protected
    
    def set_index_field_defaults field
      if index_fields.blank?
        views = default_blacklight_config.view.keys | [:show, :enabled]
        field.merge! Hash[views.map { |v| [v, true] }]
      end
    end

    # @return [Integer] the weight (sort order) for this field
    def field_weight fields, index
      if fields[index] and fields[index][:weight]
        fields[index][:weight].to_i
      else
        100 + (fields.keys.index(index) || fields.keys.length)
      end
    end
  end
end
