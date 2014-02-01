require "spec_helper"

describe "Creating a page", :type => :feature do
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator) }

  it "should be able to create new About Pages" do
    login_as exhibit_curator
    # TODO get here via navigation menus
    visit spotlight.exhibit_catalog_index_path(Spotlight::Exhibit.default)
    click_link "About pages"
    click_link "Add new Page"
    fill_in "about_page_title", :with => "New Page Title!"
    click_button "Create About page"
    expect(page).to have_content "Page was successfully created."
  end

  it "should be possible with only a title" do
    login_as exhibit_curator
    # TODO get here via navigation menus
    visit spotlight.exhibit_catalog_index_path(Spotlight::Exhibit.default)
    click_link "Feature pages"
    click_link "Add new Page"
    fill_in "feature_page_title", :with => "New Page Title!"
    click_button "Create Feature page"
    expect(page).to have_content "Page was successfully created."
  end
end
