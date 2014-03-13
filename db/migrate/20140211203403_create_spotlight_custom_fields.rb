class CreateSpotlightCustomFields < ActiveRecord::Migration
  def change
    create_table :spotlight_custom_fields do |t|
      t.references :exhibit
      t.string :slug
      t.string :field
      t.text :configuration

      t.timestamps
    end
  end
end
