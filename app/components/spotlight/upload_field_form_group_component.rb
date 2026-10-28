# frozen_string_literal: true

module Spotlight
  # Renders an upload field (Spotlight::UploadFieldConfig) on the catalog edit and upload forms through its configured component
  class UploadFieldFormGroupComponent < ViewComponent::Base
    attr_reader :form, :config, :value, :inline

    def initialize(form:, config:, value: nil, inline: false)
      @form = form
      @config = config
      @value = value
      @inline = inline
      super()
    end

    def call
      render config.component.new(
        form:,
        id: config.field_name,
        label:,
        value:,
        field_type: config.form_field_type,
        multiple: config.is_multiple?,
        inline:
      )
    end

    def label
      solr_field = Array(config.solr_field || config.field_name).first.to_s
      helpers.blacklight_config.index_fields[solr_field]&.label || config.label || solr_field
    end
  end
end
