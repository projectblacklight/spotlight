module Spotlight
  class Appearance
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    
    def initialize(configuration)
      @configuration = configuration
    end

    attr_reader :configuration
    delegate :persisted?, :exhibit, :exhibit_id, :default_per_page, :thumbnail_size,
      :default_blacklight_config, to: :configuration

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
        default_sort_fields.each do |k, field|
          s[field.label.underscore] = fields[k] && fields[k][:show]
        end
      end
    end

    def allowed_params
      default_sort_field_labels.map(&:to_sym)
    end

    def update(params)
      params[:document_index_view_types] = keep_selected_values(params[:document_index_view_types])
      params[:sort_fields] = enable_sort_fields(keep_selected_values(params[:sort_fields]))
      configuration.update(params)
    end

    def view_type_options
      default_blacklight_config.view.keys
    end

    def per_page_options
      default_blacklight_config.per_page
    end

    def sort_options
      default_sort_field_labels - ['relevance']
    end

    protected

    def default_sort_fields
      default_blacklight_config.sort_fields
    end

    def default_sort_field_labels
      default_sort_fields.map { |k, v| v.label.underscore }
    end

    def enable_sort_fields(checked_fields)
      default_sort_fields.each_with_object({}) do |(key, sf), new_val|
        new_val[key] = {show: true} if checked_fields.include?(sf.label.underscore)
      end
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
