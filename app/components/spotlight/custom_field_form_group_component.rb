# frozen_string_literal: true

module Spotlight
  # Renders an exhibit custom field on the catalog edit and upload forms through its configured component
  class CustomFieldFormGroupComponent < ViewComponent::Base
    attr_reader :form, :field, :value, :inline

    def initialize(form:, field:, value: nil, inline: false)
      @form = form
      @field = field
      @value = value
      @inline = inline
      super()
    end

    def call
      return render_deprecated_partial if deprecated_partial?

      render field.component.new(form:, id: field.slug, label: field.label, value:, field_type: field.form_field_type,
                                 multiple: field.is_multiple?, readonly: field.readonly_field?, inline:)
    end

    private

    # Applications could previously customize custom field inputs by overriding these partials
    def deprecated_partial
      "spotlight/custom_fields/form_group/#{field.field_type}"
    end

    def deprecated_partial?
      helpers.lookup_context.exists?(deprecated_partial, [], true)
    end

    def render_deprecated_partial
      Spotlight.deprecator.warn "Rendering deprecated partial #{deprecated_partial}. " \
                                'Configure a component in Spotlight::Engine.config.custom_field_types instead'
      render(partial: deprecated_partial, locals: { inline:, f: form, field:, value: })
    end
  end
end
