class ChangeWeightOnPages < ActiveRecord::Migration[4.2]
  def up
    change_column_default :spotlight_pages, :weight, from: 50, to: 1000
  end
end
