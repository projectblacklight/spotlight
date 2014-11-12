require "spec_helper"

describe "Search Facets Administration", :type => :feature do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  before { login_as exhibit_curator }

  describe "edit" do
    it "should display the facet edit screen" do
      visit spotlight.exhibit_edit_facets_path(exhibit)
      expect(page).to have_css("h1 small", text: "Search Facets")
      within("[data-id='genre_ssim']") do
        expect(page).to have_content("Genre")
        expect(page).to have_content(/\d+ items/)
        expect(page).to have_content("10 unique values")
      end
    end
  end
end
