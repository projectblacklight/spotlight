class AddWeightToExhibits < ActiveRecord::Migration[4.2]
  def up
    add_column :spotlight_exhibits, :weight, :integer, default: 50
  end
end
