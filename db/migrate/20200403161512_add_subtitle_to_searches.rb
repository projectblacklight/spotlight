class AddSubtitleToSearches < ActiveRecord::Migration[5.2]
  def change
    change_table :spotlight_searches do |t|
      t.string :subtitle
    end
  end
end
