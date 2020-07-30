# frozen_string_literal: true

##
# Value object for calculating a custom field name.
class CustomFieldName
  delegate :readonly_field?, :configuration, :field_type, to: :custom_field
  attr_reader :custom_field

  def initialize(custom_field)
    @custom_field = custom_field
  end

  def to_s
    "#{field_slug}#{field_suffix}"
  end

  private

  def field_slug
    "#{field_prefix}#{configuration['label'].parameterize}"
  end

  def field_prefix
    if readonly_field?
      'readonly_'
    else
      ''
    end
  end

  def field_suffix
    (field_type && Spotlight::Engine.config.custom_field_types[field_type.to_sym][:suffix]) ||
      default_field_suffix
  end

  def default_field_suffix
    Spotlight::Engine.config.solr_fields.text_suffix
  end
end
