require "spec_helper"

describe "Browse Category Administration" do
  let!(:search) { FactoryGirl.create(:search) }
  let(:curator) { FactoryGirl.create(:exhibit_curator) }
  let(:exhibit) { Spotlight::Exhibit.default }
  before { login_as curator }
  describe "index" do
    it "should have searches" do
      visit spotlight.exhibit_searches_path(exhibit)
      within(".panel .search") do
        expect(page).to have_css(".title", text: search.title)
      end
    end
  end
  describe "edit" do
    it "should display an edit form" do
      visit spotlight.edit_search_path(search)
      expect(page).to have_css("h2", text: "Edit Browse Category")
      expect(find_field("search_title").value).to eq search.title
    end
  end
  describe "destroy" do
    it "should destroy a tag" do
      pending("TODO: Allow searches to be destroyed without javascript")
      visit spotlight.exhibit_searches_path(exhibit)
      within(".panel .search") do
        click_link("Delete")
      end
      expect(page).to have_content("Search was deleted")
      expect(page).not_to have_content(search.title)
    end
  end
end
