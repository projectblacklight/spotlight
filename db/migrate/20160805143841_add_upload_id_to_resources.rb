class AddUploadIdToResources < ActiveRecord::Migration[4.2]
  def change
    add_column :spotlight_resources, :upload_id, :integer
    add_index :spotlight_resources, :upload_id
  end
end
