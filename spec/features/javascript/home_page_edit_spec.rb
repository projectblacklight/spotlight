require "spec_helper"

feature "Editing the Home Page", js: true do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:admin) { FactoryGirl.create(:exhibit_admin, exhibit: exhibit) }
  
  before { login_as admin }

  it "should not have a search results widget" do
    skip("Passing locally but Travis is throwing intermittent errors") if ENV["CI"]
    visit spotlight.edit_exhibit_home_page_path(exhibit)
    find("[data-icon='add']").click
    within("[data-icon='add']") do
      expect(page).to have_css("[data-type='text']")
      expect(page).not_to have_css("[data-type='search_results']", visible: true)
    end
  end
end
