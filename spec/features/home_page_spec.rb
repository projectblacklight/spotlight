require "spec_helper"
describe "Home page", :type => :feature do
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
    expect(page).to have_content("The home page was successfully updated.")

    within '.dropdown-menu' do
      click_link 'Dashboard'
    end
    click_link "Feature pages"
    expect(page).to have_content "New Home Page Title"
    expect(page).to have_selector ".panel-title a", text: "New Home Page Title"
  end

  describe "page options on edit form" do
    describe "show title" do
      let(:home_page) { FactoryGirl.create(:home_page, display_title: false, exhibit: exhibit) }
      it "should be updatable from the edit page" do
        expect(home_page.display_title).to be_falsey

        visit spotlight.edit_exhibit_home_page_path(home_page.exhibit, home_page)
        expect(find("#home_page_display_title")).not_to be_checked

        check "Show title"
        click_button "Save changes"

        visit spotlight.edit_exhibit_home_page_path(home_page.exhibit, home_page)
        expect(find("#home_page_display_title")).to be_checked
      end
    end
  end
end
