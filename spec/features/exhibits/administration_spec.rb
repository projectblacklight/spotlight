describe 'Exhibit Administration', type: :feature do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:admin) { FactoryGirl.create(:exhibit_admin, exhibit: exhibit) }
  let(:hidden_input_id_0) { 'exhibit_contact_emails_attributes_0_id' }
  let(:email_id_0) { 'exhibit_contact_emails_attributes_0_email' }
  let(:email_address_0) { 'admin@example.com' }
  let(:hidden_input_id_1) { 'exhibit_contact_emails_attributes_1_id' }
  let(:hidden_input_val_1) { '2' }
  let(:email_id_1) { 'exhibit_contact_emails_attributes_1_email' }
  let(:email_address_1) { 'admin2@example.com' }
  before { login_as admin }

  describe 'Contact Emails' do
    it 'has breadcrumbs' do
      visit spotlight.edit_exhibit_path(exhibit)
      expect(page).to have_breadcrumbs 'Home', 'Configuration', 'General'
    end

    it 'has a blank input field when there are no contacts yet' do
      visit spotlight.edit_exhibit_path(exhibit)
      expect(page).to have_css('input.exhibit-contact')
      expect(find_field(email_id_0).value).to be_blank
    end

    it 'stores and retreives a contact email address' do
      visit spotlight.edit_exhibit_path(exhibit)
      fill_in email_id_0, with: email_address_0
      click_button 'Save changes'
      expect(page).to have_content('The exhibit was successfully updated.')
      visit spotlight.edit_exhibit_path(exhibit)
      expect(find_field(email_id_0).value).to eq email_address_0
    end

    it "has new inputs added when clicking on the 'add contact' button", js: true do
      # Exhibit administration edit
      visit spotlight.edit_exhibit_path(exhibit)

      # fill in first email field
      fill_in email_id_0, with: email_address_0

      # Additonal blank fields should not exist
      expect(page).not_to have_css("input##{email_id_1}")
      # click the + (add contact) button
      find('#another-email').click
      # An additional blank field should exist now
      expect(page).to have_css("input##{email_id_1}")
      expect(find_field(email_id_1).value).to be_blank

      # fill in the second email field
      fill_in email_id_1, with: email_address_1
      click_button 'Save changes'

      expect(page).to have_content('The exhibit was successfully updated.')
      visit spotlight.edit_exhibit_path(exhibit)

      expect(find_field(email_id_0).value).to eq email_address_0
      expect(find_field(email_id_1).value).to eq email_address_1
    end

    it 'allows deletion of contact email addresses', js: true do
      # go to edit page, fill in first email field, click the + (add contact) button, fill in the second email field, click save.
      visit spotlight.edit_exhibit_path(exhibit)
      fill_in email_id_0, with: email_address_0
      find('#another-email').click
      fill_in email_id_1, with: email_address_1
      click_button 'Save changes'

      # saving should redirect back to the edit page, which should now have the contact
      # email addresses, with delete buttons now that the entries have been saved.
      expect(find_field(email_id_0).value).to eq email_address_0
      expect(find_field(email_id_1).value).to eq email_address_1
      expect(find_all('.contact-email-delete').length).to eq 2

      # delete the first address in the list
      page.accept_confirm do
        find_all('.contact-email-delete').first.click
      end

      # the page element for the first entry should now be gone, but the second should still be present
      expect(page).not_to have_css("##{email_id_0}")
      expect(find_field(email_id_1).value).to eq email_address_1

      # reload the edit page to confirm deletion from db...
      visit spotlight.edit_exhibit_path(exhibit)

      # what was the second address should now be the only one on the page, and should now be
      # in the first/only form field (form fields are numbered at page load from 0).
      expect(find_field(email_id_0).value).to eq email_address_1
      expect(page).not_to have_css("##{email_id_1}")

      # the hidden input field is what contains the underlying id of the contact for db retrieval
      expect(find("##{hidden_input_id_0}", visible: false).value).to eq hidden_input_val_1
    end

    it 'creates an empty form field with no associated delete command or confirmation status when creating a blank row for a new contact', js: true do
      # create a contact email address and save (shouldn't see delete button or confirmation status on unsaved entries)
      visit spotlight.edit_exhibit_path(exhibit)
      fill_in email_id_0, with: email_address_0
      click_button 'Save changes'

      find('#another-email').click
      expect(find_field(email_id_0).value).to eq email_address_0
      expect(find_field(email_id_1).value).to eq ''

      # conf status and email delete are nested in a sibling div of the hidden
      # id field that's used to indicate the id of the record to be updated.
      expect(page).to have_css("##{hidden_input_id_0}~div div.confirmation-status")
      expect(page).to have_css("##{hidden_input_id_0}~div span.contact-email-delete-wrapper")
      expect(page).not_to have_css("##{hidden_input_id_1}~div div.confirmation-status")
      expect(page).not_to have_css("##{hidden_input_id_1}~div span.contact-email-delete-wrapper")
      expect(find_all('.confirmation-status').length).to eq 1
      expect(find_all('.contact-email-delete-wrapper').length).to eq 1
    end

    it 'displays the error message from the server if there is one', js: true do
      visit spotlight.edit_exhibit_path(exhibit)
      fill_in email_id_0, with: email_address_0
      find('#another-email').click
      fill_in email_id_1, with: email_address_1
      click_button 'Save changes'

      Spotlight::ContactEmail.all.first.destroy
      page.accept_confirm do
        find_all('.contact-email-delete').first.click
      end

      expect(page).to have_css("##{hidden_input_id_0}~div span.contact-email-delete-error", text: 'Problem deleting contact email: Not Found')
    end
  end
end
