class AddMetadataToSpotlightResource < ActiveRecord::Migration[4.2]
  def up
    add_column :spotlight_resources, :metadata, :binary
  end

  def down
    remove_column :spotlight_resources, :metadata
  end
end
