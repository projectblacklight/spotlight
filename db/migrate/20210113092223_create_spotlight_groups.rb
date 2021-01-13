class CreateSpotlightGroups < ActiveRecord::Migration[5.2]
  def self.up
    create_table :spotlight_groups do |t|
      t.string     :slug
      t.text       :title
      t.references :exhibit
      t.integer    :weight, default: 50
      t.boolean    :published

      t.timestamps
    end

    create_table :spotlight_groups_members, id: false do |t|
      t.references :group
      t.references :member, polymorphic: true
    end
  end

  def self.down
    drop_table :spotlight_groups
    drop_table :spotlight_groups_members
  end
end
