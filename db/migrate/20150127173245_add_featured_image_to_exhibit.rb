class AddFeaturedImageToExhibit < ActiveRecord::Migration[4.2]
  def change
    add_column :spotlight_exhibits, :featured_image, :string
  end
end
