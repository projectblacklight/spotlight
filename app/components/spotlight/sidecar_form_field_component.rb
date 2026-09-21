# frozen_string_literal: true

module Spotlight
    # Allow for mulivalued field entry on catalog edit and upload forms
    class SidecarFormFieldComponent < ViewComponent::Base
      attr_reader :form, :field_id, :label, :value_list, :multiple, :readonly, :inline

      def initialize(form:, id:, label:, field_type: "text_field", value: nil, multiple: false, readonly: false, inline: false)
        super()
        @form = form
        @field_id = id
        @label = label
        @field_type = field_type.to_s
        @value_list = Array(value || "")
        @multiple = multiple
        @readonly = readonly
        @inline = inline
      end

      def render_input(value: nil, namespace: nil)
        options = {
          value: value,
          class: "form-control field-#{field_id}"
        }

        # Add multiple to options only if multiple is true
        options[:multiple] = true if multiple

         # Add readonly to options only if readonly is true
        options[:readonly] = true if readonly

        # Add namespace to options only if namespace is present
        options[:namespace] = namespace if namespace.present?
  
        case @field_type
        when "text_field", "vocab"
          form.text_field_without_bootstrap(field_id, **options)
        when "text_area", "text"
          form.text_area_without_bootstrap(field_id, **options)
        end
      end

      def template_id
        "spotlight-field-template-#{@field_id}"
      end

      def label_col
        form&.label_col
      end

      def control_col
        form&.control_col
      end
      
      def offset_col
        label_col.sub('col', 'offset')
      end
    end
  end
