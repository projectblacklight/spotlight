class AddWeightToExhibits < ActiveRecord::Migration
  def up
    add_column :spotlight_exhibits, :weight, :integer, default: 50
  end
end
