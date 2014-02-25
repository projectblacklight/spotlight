class CreateSpotlightAttachments < ActiveRecord::Migration
  def change
    create_table :spotlight_attachments do |t|
      t.string :name
      t.string :file
      t.string :uid
      t.references :exhibit

      t.timestamps
    end
  end
end
