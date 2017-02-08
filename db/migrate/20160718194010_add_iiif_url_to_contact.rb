class AddIiifUrlToContact < ActiveRecord::Migration
  def change
    add_column :spotlight_contacts, :avatar_id, :integer
    add_index :spotlight_contacts, :avatar_id
  end
end
