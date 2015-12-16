class ChangeRolesToSupportPolymorphicAssociations < ActiveRecord::Migration
  def up
    add_column :spotlight_roles, :resource_id, :integer
    add_column :spotlight_roles, :resource_type, :string

    migrate_role_data_to_polymorphic_resource

    remove_index :spotlight_roles, [:exhibit_id, :user_id]
    remove_column :spotlight_roles, :exhibit_id

    add_index :spotlight_roles, [:resource_type, :resource_id, :user_id], unique: true, name: 'index_spotlight_roles_on_resource_and_user_id'
  end

  def down
    add_column :spotlight_roles, :exhibit_id, :integer
    add_index(:spotlight_roles, [:exhibit_id])

    Spotlight::Role.reset_column_information

    Spotlight::Role.find_each do |e|
      e.update(exhibit_id: e.resource_id) if e.exhibit_id.nil? && e.resource_type == 'Spotlight::Exhibit'
    end
    
    remove_index :spotlight_roles, name: 'index_spotlight_roles_on_resource_and_user_id'

    remove_column :spotlight_roles, :resource_id
    remove_column :spotlight_roles, :resource_type

    add_index :spotlight_roles, [:exhibit_id, :user_id], unique: true
  end

  private

  def migrate_role_data_to_polymorphic_resource
    Spotlight::Role.reset_column_information

    Spotlight::Role.find_each do |e|
      e.update(resource_id: e.exhibit_id, resource_type: 'Spotlight::Exhibit') unless e.resource_id
    end
  end
end
