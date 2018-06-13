##
# Value object for calculating a custom field name.
class CustomFieldName
  delegate :readonly_field?, :configuration, to: :custom_field
  attr_reader :custom_field
  def initialize(custom_field)
    @custom_field = custom_field
  end

  def to_s
    "#{field_prefix}#{configuration['label'].parameterize}"
  end

  private

  def field_prefix
    if readonly_field?
      'readonly_'
    else
      ''
    end
  end
end
