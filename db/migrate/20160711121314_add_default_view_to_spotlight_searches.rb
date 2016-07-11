class AddDefaultViewToSpotlightSearches < ActiveRecord::Migration
  def change
    add_column :spotlight_searches, :default_index_view_type, :string
  end
end
