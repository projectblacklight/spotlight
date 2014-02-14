require "spec_helper"

describe "Metadata Administration" do
  let(:curator) { FactoryGirl.create(:exhibit_curator) }
  let(:exhibit) { Spotlight::Exhibit.default }
  before { login_as curator }
  describe "edit" do
    it "should display the metadata edit page" do
      visit spotlight.exhibit_edit_metadata_path(exhibit)
      expect(page).to have_css("h2", text: "Metadata")
      within("[data-id='language_ssm']") do
        expect(page).to have_css("td", text: "Language")
      end
    end
  end
end
