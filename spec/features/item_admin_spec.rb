require "spec_helper"

describe "Item Administration" do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  before { login_as curator }

  before do
    ::SolrDocument.any_instance.stub(reindex: true)
  end

  describe "admin" do
    it "should not have a 'Save this search' button" do
      visit spotlight.admin_exhibit_catalog_index_path(exhibit)
      expect(page).not_to have_css("button", text: "Save this search")
    end
    it "should have catalog items" do
      visit spotlight.admin_exhibit_catalog_index_path(exhibit)
      expect(page).to have_css("h1 small", text: "Items")
      expect(page).to have_css("table#documents")
      expect(page).to have_css(".pagination")
      
      item = first("tr[itemscope]")
      expect(item).to have_link "View"
      expect(item).to have_link "Edit"
    end

    it "should have a public/private toggle" do
      visit spotlight.admin_exhibit_catalog_index_path(exhibit)
      item = first("tr[itemscope]")
      expect(item).to have_button "Make Private"
      item.click_button "Make Private"

      item = first("tr[itemscope]")
      expect(item).to have_button "Make Public"
      item.click_button "Make Public"
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
