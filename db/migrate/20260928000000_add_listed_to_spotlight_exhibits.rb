class AddListedToSpotlightExhibits < ActiveRecord::Migration[7.1]
  def change
    add_column :spotlight_exhibits, :listed, :boolean, default: true, null: false
  end
end
