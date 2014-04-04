require 'spec_helper'

describe "Browse Category Administration", type: :feature, js: true do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:admin)   { FactoryGirl.create(:exhibit_admin, exhibit: exhibit) }
  before { login_as admin }
  describe "Featured Image" do
    it "should be selectable by choosing a featured item" do
      visit spotlight.edit_exhibit_search_path exhibit, exhibit.searches.first
      autocomplete_field = find("input#featured-item-title")
      fill_in_typeahead_field "search[featured_item_id]", with: "gt736xf9712"
      click_button "Save changes"
      expect(page).to have_content "The search was successfully updated."
      within(".pic.thumbnail") do
        expect(page).to have_css('img[src="https://stacks.stanford.edu/image/gt736xf9712/gt736xf9712_05_0001_thumb"]')
      end
    end
  end
end