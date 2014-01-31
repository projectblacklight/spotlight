require "spec_helper"

describe "Creating a page", :type => :feature do
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator) }

  it "should be possible with only a title" do
    login_as exhibit_curator
    # TODO get here via navigation menus
    visit spotlight.new_exhibit_page_path(Spotlight::Exhibit.default)
    fill_in "page_title", :with => "New Page Title!"
    click_button "Create Page"
    expect(page).to have_content "Page was successfully created."
  end
end
