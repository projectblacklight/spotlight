class CreateSpotlightSearches < ActiveRecord::Migration
  def change
    create_table :spotlight_searches do |t|
      t.string :title
      t.text :query_params
      t.references :exhibit
      t.timestamps
    end

    add_index :spotlight_searches, :exhibit_id
  end
end
