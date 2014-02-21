require "spec_helper"

describe "Item Administration" do
  let(:exhibit) { Spotlight::Exhibit.default }
  let(:curator) { FactoryGirl.create(:exhibit_curator) }
  before { login_as curator }
  describe "admin" do
    it "should have catalog items" do
      visit spotlight.admin_exhibit_catalog_index_path(Spotlight::Exhibit.default)
      expect(page).to have_css("h1 small", text: "Items")
      expect(page).to have_css("table#documents")
      expect(page).to have_css(".pagination")
      within "tr[itemscope]:first-child" do
        expect(page).to have_link "View"
        expect(page).to have_link "Edit"
      end
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
    it "should toggle the 'Private' label", js: true do
      visit spotlight.admin_exhibit_catalog_index_path(exhibit)
      # The label should be toggled when the checkbox is clicked
      within "tr[itemscope]:first-child" do
        expect(page).not_to have_css(".label-warning", text: "Private", visible: true)
        find("input.toggle_visibility[type='checkbox']").click
        expect(page).to have_css(".label-warning", text: "Private", visible: true)
      end

      # The label should show up on page load
      visit spotlight.admin_exhibit_catalog_index_path(exhibit)
      within "tr[itemscope]:first-child" do
        expect(page).to have_css(".label-warning", text: "Private", visible: true)
        find("input.toggle_visibility[type='checkbox']").click
        expect(page).not_to have_css(".label-warning", text: "Private", visible: true)
      end
    end
  end
end
