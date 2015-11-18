class CreateExhibits < ActiveRecord::Migration
  def change
    create_table :spotlight_exhibits do |t|
      t.string :title, null: false
      t.string :subtitle
      t.string :slug
      t.text :description
      t.timestamps
    end

    add_index :spotlight_exhibits, :slug, unique: true
  end
end
