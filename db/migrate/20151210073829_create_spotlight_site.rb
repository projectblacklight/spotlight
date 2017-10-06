class CreateSpotlightSite < ActiveRecord::Migration[4.2]
  def change
    create_table :spotlight_sites do |t|
      t.string :title
      t.string :subtitle
      t.references :masthead
    end
  end
end
