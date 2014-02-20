require "spec_helper"

describe "Item Administration" do
  let(:exhibit) { Spotlight::Exhibit.default }
  let(:curator) { FactoryGirl.create(:exhibit_curator) }
  before { login_as curator }
  describe "admin" do
    it "should have catalog items" do
      visit spotlight.admin_exhibit_catalog_index_path(Spotlight::Exhibit.default)
      expect(page).to have_css("h2", text: "Items")
      expect(page).to have_css("table#documents")
      expect(page).to have_css(".pagination")
    end

    it "should have a public/private toggle" do
      visit spotlight.admin_exhibit_catalog_index_path(Spotlight::Exhibit.default)
      within "tr[itemscope]:first-child" do
        expect(page).to have_button "Make Private"
        click_button "Make Private"
      end

      within "tr[itemscope]:first-child" do
        expect(page).to have_button "Make Public"
        click_button "Make Public"
      end
    end
  end
end
