require "spec_helper"

describe "Browse Category Administration", :type => :feature do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  let!(:search) { FactoryGirl.create(:search, exhibit: exhibit, query_params: { f: { "genre_ssim" => ["Value"]}}) }
  before { login_as curator }
  describe "index" do
    it "should have searches" do
      visit spotlight.exhibit_searches_path(exhibit)
      expect(page).to have_css(".panel .search .title", text: search.title)
    end
  end
  describe "edit" do
    it "should display an edit form" do
      visit spotlight.edit_exhibit_search_path(exhibit, search)
      expect(page).to have_css("h1 small", text: "Edit Browse Category")
      expect(find_field("search_title").value).to eq search.title
      within ".appliedFilter" do
        expect(page).to have_content "Genre"
        expect(page).to have_content "Value"
      end
    end
  end
  describe "destroy" do
    it "should destroy a tag" do
      skip("TODO: Allow searches to be destroyed without javascript")
      visit spotlight.exhibit_searches_path(exhibit)
      within(".panel .search") do
        click_link("Delete")
      end
      expect(page).to have_content("Search was deleted")
      expect(page).not_to have_content(search.title)
    end
  end
end
