require "spec_helper"

describe "Curation Mode Widget" do
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator) }
  let(:doc_id) { "dq287tq6352" }
  before {login_as exhibit_curator}
  describe "on the edit page" do
    it "should have text indicating that the user is in curation mode and a link to turn it off" do
      visit spotlight.edit_exhibit_catalog_path(Spotlight::Exhibit.default, doc_id)
      expect(page).to have_content("You are in curation mode. Turn off.")
      expect(page).to have_link("Turn off.")
    end
  end
  describe "on the show page" do
    it "should have text indicating that the user is in end-user mode and a link to turn go into curation mode" do
      visit spotlight.exhibit_catalog_path(Spotlight::Exhibit.default, doc_id)
      expect(page).to have_content("You are in end-user mode. Enter curation mode.")
      expect(page).to have_link("Enter curation mode.")
    end
  end
end