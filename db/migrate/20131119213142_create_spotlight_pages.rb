class CreateSpotlightPages < ActiveRecord::Migration
  def change
    create_table :spotlight_pages do |t|
      t.string  :title
      t.text    :content
      t.integer :weight, :default => 0
      t.boolean :display_sidebar
      t.boolean :published
      t.integer :parent_page_id

      t.timestamps
    end
  end
end
