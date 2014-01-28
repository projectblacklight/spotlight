class CreateSpotlightPages < ActiveRecord::Migration
  def change
    create_table :spotlight_pages do |t|
      t.string :title
      t.text :content

      t.timestamps
    end
  end
end
