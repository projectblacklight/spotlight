class AddMetadataToSpotlightResource < ActiveRecord::Migration
  def up
    add_column :spotlight_resources, :metadata, :binary
  end

  def down
    remove_column :spotlight_resources, :metadata
  end
end
