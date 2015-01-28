class AddFeaturedImageToExhibit < ActiveRecord::Migration
  def change
    add_column :spotlight_exhibits, :featured_image, :string
  end
end
