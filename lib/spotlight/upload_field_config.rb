# frozen_string_literal: true

module Spotlight
  ##
  # A class to model the configuration required to build the Document Upload form.
  # This configuration is also used in other places around the application (e.g. Metadata Field Config)
  # See Spotlight::Engine.config.upload_fields for where this is consumed
  # We should look into changing this to a standard blacklight field config in Blacklight 7
  class UploadFieldConfig
    attr_reader :blacklight_options, :field_name, :form_field_type
    def initialize(blacklight_options: {}, field_name:, form_field_type: :text_field, label: nil)
      @blacklight_options = blacklight_options
      @field_name = field_name
      @form_field_type = form_field_type
      @label = label || field_name
    end

    # aliasing for backwards compatability and consistency with blacklight config
    alias solr_field field_name

    # Allows a proc to be set as the label
    def label
      return @label.call if @label.is_a?(Proc)
      @label
    end
  end
end
