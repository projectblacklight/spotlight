require "spec_helper"
describe "Home page" do
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator) }
  before {login_as exhibit_curator}
  it "should exist by default on exhibits" do
    visit '/'
    within '.dropdown-menu' do
      click_link 'Curation'
    end
    click_link "Feature pages"
    expect(page).to have_selector "h3", text: "Homepage"
    expect(page).to have_selector "h3.panel-title", text: "Exhibit Home"
  end
  it "should allow users to edit the home page title" do
    visit '/'
    within '.dropdown-menu' do
      click_link 'Curation'
    end
    click_link "Feature pages"
    within(".home_page") do
      click_link "Edit"
    end
    fill_in "home_page_title", with: "New Home Page Title"
    click_button "Save changes"
    within(".home_page") do
      expect(page).to have_selector "h3.panel-title", text: "New Home Page Title"
    end
  end
end
