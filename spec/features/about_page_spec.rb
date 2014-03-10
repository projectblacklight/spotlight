require "spec_helper"

describe "About page" do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let!(:about_page1) { FactoryGirl.create(:about_page, title: "First Page", exhibit: exhibit) }
  let!(:about_page2) { FactoryGirl.create(:about_page, title: "Second Page", exhibit: exhibit) }
  describe "sidebar" do
    it "should display" do
      visit spotlight.exhibit_about_page_path(about_page1.exhibit, about_page1)
      # the sidebar should display
      within("#sidebar") do
        # within the sidebar navigation
        within("ul.sidenav") do
          # the current page should be active
          expect(page).to have_css("li.active", text: about_page1.title)
          # the other page should be linked
          expect(page).to have_css("li a", text: about_page2.title)
        end
      end
    end
  end
end
