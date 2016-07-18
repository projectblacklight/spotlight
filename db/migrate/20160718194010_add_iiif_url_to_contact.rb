class AddIiifUrlToContact < ActiveRecord::Migration
  def change
    add_column :spotlight_contacts, :iiif_url, :string
  end
end
