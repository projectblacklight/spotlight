require 'spec_helper'

describe "Add a contact to an exhibit" do
  let(:curator) { FactoryGirl.create(:exhibit_curator) }
  let(:exhibit) { curator.roles.first.exhibit }
  let!(:about_page) { FactoryGirl.create(:about_page, exhibit: exhibit) }
  before { login_as curator }
  it "should display a newly added contact in the sidebar" do
    visit spotlight.exhibit_about_pages_path(exhibit)
    click_link "Add contact"
    within "#new_contact" do
      fill_in "Name", with: "Marcus Aurelius"
      fill_in "Email", with: "marcus@rome.gov"
      fill_in "Title", with: "Emperor"
      fill_in "Location", with: "Rome"

      click_button "Save"
    end
    expect(page).to have_content "Contact created."

    within ".contacts_admin" do
      check "exhibit_contacts_attributes_0_show_in_sidebar"
    end
    within ".exhibit-contacts" do
      click_button "Save changes"
    end


    expect(page).to have_content "Contacts were successfully updated."

    within "#nested-pages" do
      click_link "View"
    end

    within "#sidebar .contacts" do
      expect(page).to have_selector ".name", text: "Marcus Aurelius"
    end
    
  end
end
