class AddMetadataToSpotlightResource < ActiveRecord::Migration
  def up
    add_column :spotlight_resources, :metadata, :blob
  end
end
