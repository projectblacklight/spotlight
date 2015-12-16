class AddIndexStatusToResources < ActiveRecord::Migration
  def change
    add_column :spotlight_resources, :index_status, :integer
    add_index :spotlight_resources, :index_status
  end
end
