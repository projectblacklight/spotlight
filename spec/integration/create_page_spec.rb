require "spec_helper"

describe "Creating a page", :type => :feature do
  it "should be possible with only a title" do
    visit spotlight.new_page_path
    fill_in "page_title", :with => "New Page Title!"
    click_button "Create Page"
    expect(page).to have_content "Page was successfully created."
  end
end