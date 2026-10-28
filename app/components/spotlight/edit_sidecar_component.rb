# frozen_string_literal: true

module Spotlight
  # Renders the sidecar (exhibit-specific metadata) fields on the catalog edit form
  class EditSidecarComponent < ViewComponent::Base
    attr_reader :form, :document, :exhibit

    def initialize(form:, document:, exhibit:)
      @form = form
      @document = document
      @exhibit = exhibit
      super()
    end

    def upload_fields
      Spotlight::Resources::Upload.fields(exhibit)
    end

    def sidecar
      @sidecar ||= document.sidecar(exhibit)
    end

    # Using `includes(:exhibit)` to ensure all fields are using the same exhibit object to take advantage of memoization
    def custom_fields
      exhibit.custom_fields.includes(:exhibit)
    end

    def upload_field_value(config)
      (sidecar.data['configured_fields'] || {})[config.field_name.to_s]
    end

    def custom_field_value(field)
      sidecar.data[field.slug.to_s] || sidecar.data[field.field.to_s]
    end

    def blank_field_warning
      t('spotlight.catalog.edit_sidecar.blank_field_warning_html',
        link: link_to(t('spotlight.configuration.sidebar.metadata'), helpers.spotlight.edit_exhibit_metadata_configuration_path(exhibit)))
    end
  end
end
