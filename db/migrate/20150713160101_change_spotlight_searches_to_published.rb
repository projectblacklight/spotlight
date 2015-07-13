class ChangeSpotlightSearchesToPublished < ActiveRecord::Migration
  def up
    rename_column :spotlight_searches, :on_landing_page, :published
  end
end
