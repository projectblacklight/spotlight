class CreateSpotlightBlacklightConfigurations < ActiveRecord::Migration
  def change
    create_table :spotlight_blacklight_configurations do |t|
      t.references :exhibit
      t.text :facet_fields
      t.text :index_fields
      t.text :search_fields
      t.text :sort_fields
      t.text :default_solr_params
      t.text :show
      t.text :index
      t.integer :default_per_page
      t.text :per_page
      t.text :document_index_view_types
      t.string :thumbnail_size

      t.timestamps
    end
  end
end
