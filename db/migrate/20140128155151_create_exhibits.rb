class CreateExhibits < ActiveRecord::Migration
  def change
    create_table :spotlight_exhibits do |t|
      t.string :name, null: false
      t.text :facets
      t.timestamps
    end

    add_index :spotlight_exhibits, :name, unique: true
  end
end
