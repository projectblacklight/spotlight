class CreateSpotlightSearches < ActiveRecord::Migration
  def change
    create_table :spotlight_searches do |t|
      t.string :title
      t.text :query_params
      t.references :user
      t.timestamps
    end

    add_index :spotlight_searches, :user_id
  end
end
