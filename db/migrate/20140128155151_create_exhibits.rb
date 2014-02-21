class CreateExhibits < ActiveRecord::Migration
  def change
    create_table :spotlight_exhibits do |t|
      t.string :name, null: false # This is for programatic lookup (route key perhaps)
      t.string :title, null: false
      t.string :subtitle
      t.text :description
      t.text :contact_emails
      t.timestamps
    end

    add_index :spotlight_exhibits, :name, unique: true
  end
end
