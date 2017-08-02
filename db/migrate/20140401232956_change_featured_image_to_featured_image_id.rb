class ChangeFeaturedImageToFeaturedImageId < ActiveRecord::Migration[4.2]
  def change
    remove_column :spotlight_searches, :featured_image, :string
    add_column :spotlight_searches, :featured_item_id, :string
  end
end
