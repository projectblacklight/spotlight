class AddThemeToSpotlightExhibits < ActiveRecord::Migration
  def change
    add_column :spotlight_exhibits, :theme, :string
  end
end
