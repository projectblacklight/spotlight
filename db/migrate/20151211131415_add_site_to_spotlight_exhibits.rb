class AddSiteToSpotlightExhibits < ActiveRecord::Migration
  def up
    add_column :spotlight_exhibits, :site_id, :integer
    add_index :spotlight_exhibits, :site_id

    add_default_site_to_exhibits
  end

  def down
    remove_column :spotlight_exhibits, :site_id, :integer
  end

  private

  def add_default_site_to_exhibits
    Spotlight::Site.reset_column_information
    Spotlight::Exhibit.reset_column_information

    Spotlight::Exhibit.find_each do |e|
      e.site = Spotlight::Site.instance
    end
  end
end
