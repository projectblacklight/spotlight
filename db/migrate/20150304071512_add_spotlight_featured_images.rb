class AddSpotlightFeaturedImages < ActiveRecord::Migration
  def change
    create_table :spotlight_featured_images do |t|
      t.string :image
      t.string :source
      t.string :document_global_id
      t.integer :image_crop_x, :integer
      t.integer :image_crop_y, :integer
      t.integer :image_crop_w, :integer
      t.integer :image_crop_h, :integer
      t.references :parent, polymorphic: true, index: true
      t.timestamps
    end
  end
end
