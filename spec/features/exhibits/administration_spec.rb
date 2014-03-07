require "spec_helper"

describe "Exhibit Administration" do
  let!(:exhibit) { Spotlight::ExhibitFactory.default }
  let(:admin) { FactoryGirl.create(:exhibit_admin) }
  let(:email_id_0) { "exhibit_contact_emails_attributes_0_email" }
  let(:email_address_0) { "admin@example.com" }
  let(:email_id_1) { "exhibit_contact_emails_attributes_1_email" }
  let(:email_address_1) { "admin2@example.com" }
  before { login_as admin }

  describe "Contact Emails" do
    it "should have a blank input field when there are no contacts yet" do
      visit spotlight.edit_exhibit_path( Spotlight::ExhibitFactory.default )
      expect(page).to have_css("input.exhibit-contact")
      expect(find_field(email_id_0).value).to be_blank
    end
    it "should store and retreive a contact email address" do
      visit spotlight.edit_exhibit_path( Spotlight::ExhibitFactory.default )
      fill_in email_id_0, with: email_address_0
      click_button "Save changes"
      expect(page).to have_content("The exhibit was saved.")
      visit spotlight.edit_exhibit_path( Spotlight::ExhibitFactory.default )
      expect(find_field(email_id_0).value).to eq email_address_0
    end
    it "should do something", js: true do
      # Exhibit administration edit
      visit spotlight.edit_exhibit_path( Spotlight::ExhibitFactory.default )

      # fill in first email field
      fill_in email_id_0, with: email_address_0

      # Additonal blank fields should not exist
      expect(page).not_to have_css("input##{email_id_1}")
      # click the + (add contact) button
      find("#another-email").click
      # An additional blank field should exist now
      expect(page).to have_css("input##{email_id_1}")
      expect(find_field(email_id_1).value).to be_blank

      # fill in the second email field
      fill_in email_id_1, with: email_address_1
      click_button "Save changes"

      expect(page).to have_content("The exhibit was saved.")
      visit spotlight.edit_exhibit_path( Spotlight::ExhibitFactory.default )

      expect(find_field(email_id_0).value).to eq email_address_0
      expect(find_field(email_id_1).value).to eq email_address_1
    end
  end
end
