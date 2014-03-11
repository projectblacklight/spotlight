class CreateResources < ActiveRecord::Migration
  def change
    create_table(:spotlight_resources) do |t|
      t.references :exhibit
      t.string     :type
      t.string     :url
      t.text       :data
      t.datetime   :indexed_at
      t.timestamps
    end
  end
end
