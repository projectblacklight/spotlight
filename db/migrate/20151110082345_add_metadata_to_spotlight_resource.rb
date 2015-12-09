class AddMetadataToSpotlightResource < ActiveRecord::Migration
  def up
    # postgresql does not have a blob type
    conn_type = connection.adapter_name.downcase.to_sym
    field_type = (conn_type == :postgresql) ? :bytea : :blob
    add_column :spotlight_resources, :metadata, field_type
  end

  def down
    remove_column :spotlight_resources, :metadata
  end
end
