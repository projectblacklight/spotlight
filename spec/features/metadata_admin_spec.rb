require "spec_helper"

describe "Metadata Administration" do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  before { login_as exhibit_curator }

  describe "edit" do
    it "should display the metadata edit page" do
      visit spotlight.exhibit_edit_metadata_path(exhibit)
      expect(page).to have_css("h1 small", text: "Metadata")
      within("[data-id='language_ssm']") do
        expect(page).to have_css("td", text: "Language")
      end
    end
  end
end
