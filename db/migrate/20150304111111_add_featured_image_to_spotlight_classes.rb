class AddFeaturedImageToSpotlightClasses < ActiveRecord::Migration
  
  def change
    add_column :spotlight_searches, :masthead_id, :integer
    add_column :spotlight_searches, :thumbnail_id, :integer
    add_column :spotlight_exhibits, :masthead_id, :integer
    add_column :spotlight_exhibits, :thumbnail_id, :integer
    add_column :spotlight_pages, :thumbnail_id, :integer
  end
end