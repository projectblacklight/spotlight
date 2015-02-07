module Spotlight
  class Appearance
    extend ActiveModel::Naming
    extend ActiveModel::Translation
    include ActiveModel::Conversion

    def initialize(configuration)
      @configuration = configuration
    end

    attr_reader :configuration
    delegate :persisted?, :exhibit, :exhibit_id, :default_per_page,
      :default_blacklight_config, to: :configuration

    delegate :main_navigations, :searchable, to: :exhibit

    ##
    # This enables us to have a group of checkboxes that is backed by the array
    # stored in Spotlight::BlacklightConfiguration#document_index_view_types
    def document_index_view_types
      vals = configuration.document_index_view_types
      Blacklight::OpenStructWithHashAccess.new.tap do |s|
        view_type_options.each do |k|
          s[k] = vals.include?(k.to_s)
        end
      end
    end

    ##
    # This enables us to have a group of checkboxes that is backed by the array
    # stored in Spotlight::BlacklightConfiguration#default_sort_fields
    def sort_fields 
      fields = configuration.sort_fields
      Blacklight::OpenStructWithHashAccess.new.tap do |s|
        default_sort_fields.each_with_index do |(k, field), index|
          s[k] = Blacklight::OpenStructWithHashAccess.new.tap do |c|
            c.enabled = fields[k] && fields[k][:enabled]
            c.label = fields[k][:label] if fields[k]
            c.weight = index + 1
          end
        end
      end
    end

    def allowed_params
      sort_fields.keys.each_with_object({}) do |field, hsh|
        hsh[field] = [:enabled, :label, :weight]
      end
    end

    def update(params)
      configuration.exhibit.update(exhibit_params(params))
      configuration.update(configuration_params(params))
    end

    def view_type_options
      default_blacklight_config.view.select { |k,v| v.if != false }.keys
    end

    def per_page_options
      default_blacklight_config.per_page
    end

    def default_sort_field
      configuration.blacklight_config.default_sort_field.key
    end

    protected

    def default_sort_fields
      default_blacklight_config.sort_fields
    end

    def configuration_params(params)
      p = params.except(:main_navigations, :searchable)
      p[:document_index_view_types] = keep_selected_values(p[:document_index_view_types])
      p
    end

    def exhibit_params(params)
      p = {searchable: params[:searchable]}
      if main_nav_attributes = params[:main_navigations].try(:values)
        p[:main_navigations_attributes] = main_nav_attributes
      end
      p
    end

    ##
    # A group of checkboxes on a form returns values like this:
    #   {"list"=>["0", "1"], "gallery"=>["0", "1"], "map"=>["0"]}
    # where, "list" and "gallery" are selected and "map" is not. This function
    # digests that hash into a list of selected values. e.g.:
    #   ["list", "gallery"]
    def keep_selected_values h
      return if h.nil?
      h.each_with_object([]) { |(k, v), o| o << k if v.include?("1")}
    end
  end
end
