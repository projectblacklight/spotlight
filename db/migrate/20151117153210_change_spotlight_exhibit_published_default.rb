class ChangeSpotlightExhibitPublishedDefault < ActiveRecord::Migration[4.2]
  def up
    change_column :spotlight_exhibits, :published, :boolean, default: false
  end
end