# frozen_string_literal: true

class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :spotlight_events do |t|
      t.references :exhibit, null: true
      t.references :resource, null: false, polymorphic: true, index: true
      t.string :type
      t.string :collation_key
      t.text :data

      t.timestamps
    end
  end
end
