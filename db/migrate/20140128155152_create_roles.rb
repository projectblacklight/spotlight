class CreateRoles < ActiveRecord::Migration
  def change
    create_table :spotlight_roles do |t|
      t.references :exhibit
      t.references :user
      t.string :role
    end

    add_index :spotlight_roles, [:exhibit_id, :user_id], unique: true
  end
end
