class CreateContactEmails < ActiveRecord::Migration
  def change
    create_table(:spotlight_contact_emails) do |t|
      t.references :exhibit
      t.string     :email, :null => false, :default => ""
      t.string     :confirmation_token
      t.datetime   :confirmed_at
      t.datetime   :confirmation_sent_at
      t.string     :unconfirmed_email
      t.timestamps
    end

    add_index :spotlight_contact_emails, [:email, :exhibit_id], :unique => true
    add_index :spotlight_contact_emails, :confirmation_token,   :unique => true
  end
end
