require 'blacklight/utils'

module Spotlight
  ##
  # Exhibit-specific blacklight configuration model
  # rubocop:disable Metrics/ClassLength
  class BlacklightConfiguration < ActiveRecord::Base
    belongs_to :exhibit, touch: true
    serialize :facet_fields, Hash
    serialize :index_fields, Hash
    serialize :search_fields, Hash
    serialize :sort_fields, Hash
    serialize :default_solr_params, Hash
    serialize :show, Hash
    serialize :index, Hash
    serialize :per_page, Array
    serialize :document_index_view_types, Array

    include Spotlight::BlacklightConfigurationDefaults
    include Spotlight::ImageDerivatives

    delegate :document_model, to: :default_blacklight_config

    # get rid of empty values
    before_validation do |model|
      model.index_fields.each do |_k, v|
        v[:enabled] ||= v.any? { |_k1, v1| !v1.blank? }

        default_blacklight_config.view.keys.each do |view|
          v[view] &&= value_to_boolean(v[view])
        end

        v[:show] &&= value_to_boolean(v[:show])
        v.reject! { |_k, v1| v1.blank? && v1 != false }
      end if model.index_fields

      model.facet_fields.each do |_k, v|
        v[:show] &&= value_to_boolean(v[:show])
        v[:show] ||= true if v[:show].nil?
        v.reject! { |_k, v1| v1.blank? && v1 != false }
      end if model.facet_fields

      model.search_fields.each do |k, v|
        v[:enabled] &&= value_to_boolean(v[:enabled])
        v[:enabled] ||= true if v[:enabled].nil?
        v[:label] = default_blacklight_config.search_fields[k][:label] if default_blacklight_config.search_fields[k] && !v[:label].present?
        v.reject! { |_k, v1| v1.blank? && v1 != false }
      end if model.search_fields

      model.sort_fields.each do |k, v|
        v[:enabled] &&= value_to_boolean(v[:enabled])
        v[:enabled] ||= true if v[:enabled].nil?
        v[:label] = default_blacklight_config.sort_fields[k][:label] if default_blacklight_config.sort_fields[k] && !v[:label].present?
        v.reject! { |_k, v1| v1.blank? && v1 != false }
      end if model.sort_fields

      model.per_page.reject!(&:blank?) if model.per_page
      model.document_index_view_types.reject!(&:blank?) if model.document_index_view_types
    end

    ##
    # Serialize this configuration to a Blacklight::Configuration object
    # appropriate to the current view. If a value isn't set in this record,
    # it will use the configuration set upstream (in default_blacklight_config)
    # @param [String] view the configuration may be different depending on the index view selected
    # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize
    def blacklight_config
      @blacklight_config ||= begin
        # Create a new config based on the defaults
        config = default_blacklight_config.inheritable_copy

        config.show.merge! show unless show.blank?
        config.index.merge! index unless index.blank?

        config.index.thumbnail_field ||= Spotlight::Engine.config.thumbnail_field

        config.add_results_collection_tool 'save_search', if: :render_save_this_search?

        config.default_solr_params = config.default_solr_params.merge(default_solr_params)

        config.view.embed.partials ||= ['openseadragon']
        config.view.embed.if = false
        config.view.embed.locals ||= { osd_container_class: '' }

        # Add any custom fields
        config.index_fields.merge! custom_index_fields
        config.index_fields = Hash[config.index_fields.sort_by { |k, _v| field_weight(index_fields, k) }]
        config.index_fields.reject! { |_k, v| v.if == false }

        # Update with customizations
        config.index_fields.each do |k, v|
          if index_fields[k]
            v.merge! index_fields[k].symbolize_keys
          elsif custom_index_fields[k]
            set_custom_field_defaults(v)
          else
            set_index_field_defaults(v)
          end
          v.upstream_if = v.if unless v.if.nil?
          v.if = :field_enabled?

          v.normalize! config
          v.validate!
        end

        config.show_fields.reject! { |_k, v| v.if == false }

        config.show_fields.reject { |k, _v| config.index_fields[k] }.each do |k, v|
          config.index_fields[k] = v

          if index_fields[k]
            v.merge! index_fields[k].symbolize_keys
          else
            set_show_field_defaults(v)
          end

          v.upstream_if = v.if unless v.if.nil?
          v.if = :field_enabled?

          v.normalize! config
          v.validate!
        end

        config.show_fields = config.index_fields

        unless search_fields.blank?
          config.search_fields = Hash[config.search_fields.sort_by { |k, _v| field_weight(search_fields, k) }]

          config.search_fields.each do |k, v|
            v.upstream_if = v.if unless v.if.nil?
            v.if = :field_enabled?
            next if search_fields[k].blank?

            v.merge! search_fields[k].symbolize_keys
            v.normalize! config
            v.validate!
          end
        end

        unless sort_fields.blank?
          config.sort_fields = Hash[config.sort_fields.sort_by { |k, _v| field_weight(sort_fields, k) }]

          config.sort_fields.each do |k, v|
            v.upstream_if = v.if unless v.if.nil?
            v.if = :field_enabled?
            next if sort_fields[k].blank?

            v.merge! sort_fields[k].symbolize_keys
            v.normalize! config
            v.validate!
          end
        end

        config.facet_fields.merge! custom_facet_fields
        unless facet_fields.blank?
          config.facet_fields = Hash[config.facet_fields.sort_by { |k, _v| field_weight(facet_fields, k) }]

          config.facet_fields.each do |k, v|
            next if facet_fields[k].blank?

            v.merge! facet_fields[k].symbolize_keys
            v.upstream_if = v.if unless v.if.nil?
            v.enabled = v.show
            v.if = :field_enabled?
            v.normalize! config
            v.validate!
          end
        end

        config.per_page = (config.per_page & per_page) unless per_page.blank?

        if default_per_page
          config.per_page.delete(default_per_page)
          config.per_page.unshift(default_per_page)
        end

        config.view.each do |k, v|
          v.key = k
          v.upstream_if = v.if unless v.if.nil?
          v.if = :enabled_in_spotlight_view_type_configuration?
        end unless document_index_view_types.blank?

        if config.search_fields.blank?
          config.navbar.partials[:saved_searches].if = false if config.navbar.partials.key? :saved_searches
          config.navbar.partials[:search_history].if = false if config.navbar.partials.key? :search_history
        end

        config
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

    def custom_index_fields
      Hash[exhibit.custom_fields.map do |x|
        field = Blacklight::Configuration::IndexField.new x.configuration.merge(
          key: x.field, field: x.solr_field
        )
        [x.field, field]
      end]
    end

    def custom_facet_fields
      Hash[exhibit.custom_fields.vocab.map do |x|
        field = Blacklight::Configuration::FacetField.new x.configuration.merge(
          key: x.field, field: x.solr_field, show: false
        )
        [x.field, field]
      end]
    end

    ##
    # Get the "upstream" blacklight configuration to use
    def default_blacklight_config
      @default_blacklight_config ||= begin
        config = Spotlight::Engine.blacklight_config.deep_copy
        add_exhibit_specific_fields(config)
        config
      end
    end

    # Parse params checkbox arrays into simple arrays.
    # A group of checkboxes on a form returns values like this:
    #   {"list"=>"1", "gallery"=>"1", "map"=>"0"}
    # where, "list" and "gallery" are selected and "map" is not. This function
    # digests that hash into a list of selected values. e.g.:
    #   ["list", "gallery"]
    def document_index_view_types=(hash_or_array)
      if hash_or_array.is_a? Hash
        super(hash_or_array.select { |_, checked| checked == '1' }.keys)
      else
        super(hash_or_array)
      end
    end

    # @return [OpenStructWithHashAccess] keys are view types; value is 1 if enabled
    # A group of checkboxes on a form needs values like this:
    #   {"list"=>"1", "gallery"=>"1", "map"=>"0"}
    # where, "list" and "gallery" are selected and "map" is not. This function
    # takes ["list", "gallery"] and turns it into the above.
    def document_index_view_types_selected_hash
      selected_view_types = document_index_view_types
      avail_view_types = default_blacklight_config.view.select { |_k, v| v.if != false }.keys
      Blacklight::OpenStructWithHashAccess.new.tap do |s|
        avail_view_types.each do |k|
          s[k] = selected_view_types.include?(k.to_s)
        end
      end
    end

    protected

    def add_exhibit_specific_fields(config)
      add_exhibit_tags_fields(config)
      add_uploaded_resource_fields(config)
      add_autocomplete_field(config)
    end

    def add_exhibit_tags_fields(config)
      # rubocop:disable Style/GuardClause
      unless config.show_fields.include? :exhibit_tags
        config.add_show_field :exhibit_tags, field: config.document_model.solr_field_for_tagger(exhibit), link_to_search: true
      end

      unless config.facet_fields.include? :exhibit_tags
        config.add_facet_field :exhibit_tags, field: config.document_model.solr_field_for_tagger(exhibit)
      end
      # rubocop:enable Style/GuardClause
    end

    def add_uploaded_resource_fields(config)
      exhibit.uploaded_resource_fields.each do |f|
        add_uploaded_resource_field(config, f)
      end
    end

    def add_uploaded_resource_field(config, f)
      key = Array(f.solr_field || f.field_name).first.to_s

      return if config.index_fields.any? { |_k, v| v.field == key }

      options = f.blacklight_options || {}
      options[:label] = f.label if f.label

      config.add_index_field key, options
    end

    def add_autocomplete_field(config)
      return unless Spotlight::Engine.config.autocomplete_search_field && !config.search_fields[Spotlight::Engine.config.autocomplete_search_field]

      config.add_search_field(Spotlight::Engine.config.autocomplete_search_field) do |field|
        field.include_in_simple_select = false
        field.solr_parameters = Spotlight::Engine.config.default_autocomplete_params.deep_dup
        field.solr_parameters[:fl] ||= default_autocomplete_field_list(config)
      end
    end

    def default_autocomplete_field_list(config)
      "#{config.document_model.unique_key} #{config.view_config(:show).title_field} #{spotlight_image_version_fields.join(' ')}"
    end

    def spotlight_image_version_fields
      spotlight_image_derivatives.map do |version|
        version[:field]
      end
    end

    # rubocop:disable Style/AccessorMethodName
    def set_index_field_defaults(field)
      return unless index_fields.blank?

      views = default_blacklight_config.view.keys | [:show, :enabled]
      field.merge! Hash[views.map { |v| [v, true] }]
    end

    def set_show_field_defaults(field)
      return unless index_fields.blank?
      views = default_blacklight_config.view.keys
      field.merge! Hash[views.map { |v| [v, false] }]
      field.enabled = true
      field.show = true
    end

    def set_custom_field_defaults(field)
      field.show = true
      field.enabled = true
    end
    # rubocop:enable Style/AccessorMethodName

    # @return [Integer] the weight (sort order) for this field
    def field_weight(fields, index)
      if fields[index] && fields[index][:weight]
        fields[index][:weight].to_i
      else
        100 + (fields.keys.index(index) || fields.keys.length)
      end
    end

    def value_to_boolean(v)
      if defined? ActiveRecord::Type
        # Rails 4.2+
        ActiveRecord::Type::Boolean.new.type_cast_from_database v
      else
        ActiveRecord::ConnectionAdapters::Column.value_to_boolean v
      end
    end
  end
end
