class AddFieldTypeToCustomFields < ActiveRecord::Migration
  def up
    add_column :spotlight_custom_fields, :field_type, :string

    Spotlight::CustomField.reset_column_information
    Spotlight::CustomField.update_all field_type: 'text'
  end
  def down
    remove_column :spotlight_custom_fields, :field_type
  end
end
