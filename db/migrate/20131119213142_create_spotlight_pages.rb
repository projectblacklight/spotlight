class CreateSpotlightPages < ActiveRecord::Migration
  def change
    create_table :spotlight_pages do |t|
      t.string     :title
      t.string     :type
      t.string :slug
      t.string :scope
      t.text       :content
      t.integer    :weight, default: 50
      t.boolean    :published
      t.references :exhibit
      t.integer :created_by_id
      t.integer :last_edited_by_id
      t.timestamps
      t.integer :parent_page_id
      t.boolean :display_sidebar
      t.boolean :display_title
    end
    add_index :spotlight_pages, :exhibit_id
    add_index :spotlight_pages, :parent_page_id
    add_index :spotlight_pages, [:slug,:scope], unique: true
  end
end
