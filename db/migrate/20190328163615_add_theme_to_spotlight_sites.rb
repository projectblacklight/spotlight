class AddThemeToSpotlightSites < ActiveRecord::Migration[5.1]
  def change
    add_column :spotlight_sites, :theme, :string
  end
end
