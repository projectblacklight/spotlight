class ChangeContactDetails < ActiveRecord::Migration
  def up
    add_column :spotlight_contacts, :contact_info, :text

    Spotlight::Contact.find_each do |contact|
      migrated_contact_info = {}
      attributes.each do |attribute|
        if (value = contact.send(attribute)).present?
          migrated_contact_info[attribute] = value
        end
      end
      contact.contact_info = migrated_contact_info
      contact.save!
    end

    attributes.each do |col|
      remove_column :spotlight_contacts, col, :string if Spotlight::Contact.column_names.include? col
    end
  end
  def down
    attributes.each do |attribute|
      add_column :spotlight_contacts, col, :string
    end

    Spotlight::Contact.find_each do |contact|
      attributes.each do |attribute|
        if (value = contact.contact_info[attribute]).present?
          contact.send("#{attribute}=".to_sym, value)
        end
      end
      contact.save!
    end

    remove_column :spotlight_contacts, :contact_info, :text
  end
  private
  def attributes
    [:email, :title, :location, :telephone]
  end
end
