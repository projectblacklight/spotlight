class AddSearchBoxToSpotlightSearches < ActiveRecord::Migration[5.0]
  def change
    add_column :spotlight_searches, :search_box, :boolean, default: false
  end
end
