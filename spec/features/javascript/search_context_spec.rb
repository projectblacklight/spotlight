require "spec_helper"

feature "Search contexts" do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  before { login_as exhibit_curator }

  scenario "should add context breadcrumbs back to the home page when navigating to an item from the home page", :js => true do
    skip("Passing locally but Travis is throwing intermittent error because it doesn't seem to wait for form to be submitted.") if ENV["CI"]
    # create page
    visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)

    click_link "Edit"

    # click to add widget
    find("[data-icon='add']").click
    # click the item + image widget
    expect(page).to have_css("a[data-type='item-text']")
    find("a[data-type='item-text']").click
    # fill in the hidden record ID field
    # TODO: Do we need an additional test for the typeahead?
    item_id_field = find("input[name='item-id']", visible: false)
    item_id_field.set("dq287tq6352")
    # create the page
    click_button("Save changes")
    # verify that the page was created
    expect(page).to have_content("The home page was successfully updated")
    # verify that the item + image widget is displaying an image from the document.
    within(:css, ".item-text") do
      expect(page).to have_css(".thumbnail")
      expect(page).to have_css(".thumbnail a img")
      expect(page).not_to have_css(".title")
    end

    find('.thumbnail a').click

    expect(page).to have_selector '.breadcrumb a', text: "Home"
  end

  scenario "should add context breadcrumb back to the feature page when navigating to an item from a feature page", :js => true do
    skip("Passing locally but Travis is throwing intermittent error because it doesn't seem to wait for form to be submitted.") if ENV["CI"]
    # create page
    visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)
    click_link exhibit_curator.email
    within '.dropdown-menu' do
      click_link 'Dashboard'
    end
    click_link "Feature pages"

    add_new_page_via_button("My New Feature Page")

    expect(page).to have_css("h3", text: "My New Feature Page")

    expect(page).to have_content("The feature page was created.")
    within("li.dd-item") do
      click_link "Edit"
    end
    # fill in title
    fill_in "feature_page_title", :with => "Exhibit Title"
    # click to add widget
    find("[data-icon='add']").click
    # click the item + image widget
    expect(page).to have_css("a[data-type='item-text']")
    find("a[data-type='item-text']").click
    # fill in the hidden record ID field
    # TODO: Do we need an additional test for the typeahead?
    item_id_field = find("input[name='item-id']", visible: false)
    item_id_field.set("dq287tq6352")
    # create the page
    click_button("Save changes")
    # verify that the page was created
    expect(page).to have_content("The feature page was successfully updated.")
    # verify that the item + image widget is displaying an image from the document.
    within(:css, ".item-text") do
      expect(page).to have_css(".thumbnail")
      expect(page).to have_css(".thumbnail a img")
      expect(page).not_to have_css(".title")
    end

    find('.thumbnail a').click

    expect(page).to have_selector '.breadcrumb a', text: "Home"
    expect(page).to have_link "Exhibit Title", href: spotlight.exhibit_feature_page_path(exhibit, Spotlight::FeaturePage.last)
  end

  scenario "should add context breadcrumbs back to the browse page when navigating to an item from a browse page", :js => true do
    skip("Passing locally but Travis is throwing intermittent error because it doesn't seem to wait for form to be submitted.") if ENV["CI"]
    search = Spotlight::Search.create! exhibit_id: exhibit.id, title: "Some Saved Search", on_landing_page: true
    visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)
    click_link "Browse"
    click_link "Some Saved Search"
    click_link "A MAP of AMERICA from the latest and best Observations"
    expect(page).to have_link "Home"
    expect(page).to have_link "Browse"
    expect(page).to have_link "Some Saved Search", href: spotlight.exhibit_browse_path(exhibit, search)

  end
end
