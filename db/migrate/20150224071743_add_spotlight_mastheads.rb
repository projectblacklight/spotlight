class AddSpotlightMastheads < ActiveRecord::Migration
  def change
    create_table :spotlight_mastheads do |t|
      t.boolean :display
      t.string :image
      t.string :source
      t.string :document_global_id
      t.integer :image_crop_x, :integer
      t.integer :image_crop_y, :integer
      t.integer :image_crop_w, :integer
      t.integer :image_crop_h, :integer
      t.references :exhibit
      t.timestamps
    end
    add_index :spotlight_mastheads, :exhibit_id
  end
end
