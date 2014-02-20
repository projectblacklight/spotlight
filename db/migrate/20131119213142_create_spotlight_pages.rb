class CreateSpotlightPages < ActiveRecord::Migration
  def change
    create_table :spotlight_pages do |t|
      t.string     :title
      t.string     :type
      t.text       :content
      t.integer    :weight, default: 50
      t.boolean    :published
      t.references :exhibit
      t.integer :created_by_id
      t.integer :last_edited_by_id
      t.timestamps
      t.integer :parent_page_id
      t.boolean :display_sidebar
    end
    add_index :spotlight_pages, :exhibit_id
    add_index :spotlight_pages, :parent_page_id
  end
end
