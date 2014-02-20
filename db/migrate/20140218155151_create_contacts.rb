class CreateContacts < ActiveRecord::Migration
  def change
    create_table :spotlight_contacts do |t|
      t.string :name
      t.string :email
      t.string :title
      t.string :location
      t.boolean :show_in_sidebar
      t.references :exhibit
      t.timestamps
    end

    add_index :spotlight_contacts, :exhibit_id
  end
end
