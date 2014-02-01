class CreateSpotlightPages < ActiveRecord::Migration
  def change
    create_table :spotlight_feature_pages do |t|
      define_table(t)
      t.integer :parent_page_id
      t.boolean :display_sidebar
    end
    create_table :spotlight_about_pages do |t|
      define_table(t)
    end
    add_index :spotlight_feature_pages, :exhibit_id
    add_index :spotlight_feature_pages, :parent_page_id
    add_index :spotlight_about_pages,   :exhibit_id
  end
  def define_table(t)
    t.string     :title
    t.text       :content
    t.integer    :weight, :default => 0
    t.boolean    :published
    t.references :exhibit
    t.timestamps
  end
end
