class CreateSpotlightLanguages < ActiveRecord::Migration[5.0]
  def change
    create_table :spotlight_languages do |t|
      t.string :locale, null: false
      t.boolean :public
      t.string :text
      t.references :exhibit

      t.timestamps
    end
  end
end
