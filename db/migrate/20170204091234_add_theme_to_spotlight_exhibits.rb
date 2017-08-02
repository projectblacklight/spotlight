class AddThemeToSpotlightExhibits < ActiveRecord::Migration[4.2]
  def change
    add_column :spotlight_exhibits, :theme, :string
  end
end
