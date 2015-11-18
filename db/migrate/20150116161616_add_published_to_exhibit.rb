class AddPublishedToExhibit < ActiveRecord::Migration
  def change
    add_column :spotlight_exhibits, :published, :boolean, default: false
    add_column :spotlight_exhibits, :published_at, :datetime
    
    reversible do |dir|
      dir.up do
        Spotlight::Exhibit.find_each do |e|
          e.published = true
          e.save!
        end
      end
    end
  end
end
