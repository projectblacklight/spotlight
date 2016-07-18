class AddIiifUrlToFeaturedImage < ActiveRecord::Migration
  def change
    add_column :spotlight_featured_images, :iiif_url, :string
  end
end
