class AddContentTypeToPages < ActiveRecord::Migration[4.2]
  def up
    add_column :spotlight_pages, :content_type, :string
  end
end
