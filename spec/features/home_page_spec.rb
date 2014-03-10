require "spec_helper"
describe "Home page" do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  before {login_as exhibit_curator}
  it "should exist by default on exhibits" do
    visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)
    within '#user-util-collapse .dropdown-menu' do
      click_link 'Dashboard'
    end
    click_link "Feature pages"
    expect(page).to have_selector "h3", text: "Homepage"
    expect(page).to have_selector "h3.panel-title", text: "Exhibit Home"
  end

  it "should allow users to edit the home page title" do
    visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)
    within '#user-util-collapse .dropdown-menu' do
      click_link 'Dashboard'
    end
    click_link "Feature pages"
    within(".home_page") do
      click_link "Edit"
    end
    fill_in "home_page_title", with: "New Home Page Title"
    click_button "Save changes"
    expect(page).to have_content("Page was successfully updated.")

    within '.dropdown-menu' do
      click_link 'Dashboard'
    end
    click_link "Feature pages"
    expect(page).to have_content "New Home Page Title"
    expect(page).to have_selector ".panel-title a", text: "New Home Page Title"
  end

  it "should allow users to edit the display_title attribute" do
    visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)
    within '#user-util-collapse .dropdown-menu' do
      click_link 'Dashboard'
    end

    click_link "Feature pages"

    # Choose to display the home page title
    within(".home_page") do
      check "Show title"
    end
    click_button "Save changes"

    visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)

    # Verify the home page title is being displayed
    expect(page).to have_css("h1.page-title", text: exhibit.home_page.title)

    within '.dropdown-menu' do
      click_link 'Dashboard'
    end

    click_link "Feature pages"

    # Choose to not display the home page title
    within(".home_page") do
      uncheck "Show title"
    end
    click_button "Save changes"

    visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)

    # Verify the home page title is not being displayed
    expect(page).not_to have_css("h1.page-title", text: exhibit.home_page.title)
  end
end
