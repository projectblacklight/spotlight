class AddUploadIdToResources < ActiveRecord::Migration
  def change
    add_column :spotlight_resources, :upload_id, :integer
    add_index :spotlight_resources, :upload_id
  end
end
