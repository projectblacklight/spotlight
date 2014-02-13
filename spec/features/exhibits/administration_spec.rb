require "spec_helper"

describe "Exhibit Administration" do
  let(:admin) { FactoryGirl.create(:exhibit_admin) }
  let(:email_id) { "exhibit_contact_emails_attributes_0_email" }
  let(:email_address) { "admin@example.com" }
  before { login_as admin }

  describe "Contact Emails" do
    it "should have a blank input field when there are no contacts yet" do
      visit spotlight.edit_exhibit_path( Spotlight::Exhibit.default )
      expect(page).to have_css("input.exhibit-contact")
      expect(find_field(email_id).value).to be_blank
    end
    it "should store and retreive a contact email address" do
      visit spotlight.edit_exhibit_path( Spotlight::Exhibit.default )
      fill_in email_id, with: email_address
      click_button "Save changes"
      expect(page).to have_content("The exhibit was saved.")
      visit spotlight.edit_exhibit_path( Spotlight::Exhibit.default )
      expect(find_field(email_id).value).to eq email_address
    end
  end
end
