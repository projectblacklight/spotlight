class ChangeSpotlightExhibitPublishedDefault < ActiveRecord::Migration
  def up
    change_column :spotlight_exhibits, :published, :boolean, default: false
  end
end