class AddRoleMaskToRoles < ActiveRecord::Migration[5.2]
  def change
    add_column :spotlight_roles, :role_mask, :string
  end
end
