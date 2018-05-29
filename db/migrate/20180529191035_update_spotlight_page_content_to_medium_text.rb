class UpdateSpotlightPageContentToMediumText < ActiveRecord::Migration[5.0]
  def change
    change_column :spotlight_pages, :content, :text, limit: 16_777_215
  end
end
