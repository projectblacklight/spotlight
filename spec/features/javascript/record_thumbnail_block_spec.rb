require "spec_helper"

feature "Record Thumbnail Block" do
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator) }
  before { login_as exhibit_curator }

  scenario "should allow you to add a thumbnail to a page within an exhibit", :js => true do
    # create page
    # TODO find this via a menu
    visit spotlight.exhibit_catalog_index_path(Spotlight::Exhibit.default)
    click_link "Feature pages"
    click_link "Add new Page"
    # fill in title
    fill_in "feature_page_title", :with => "Exhibit Title"
    # click to add widget
    find("[data-icon='add']").click
    # click the Record Thumbnail widget
    expect(page).to have_css("a[data-type='record-thumbnail']")
    find("a[data-type='record-thumbnail']").click
    # fill in the record ID field
    expect(page).to have_css("input#record-thumbnail-id")
    fill_in "record-thumbnail-id", :with => "dq287tq6352"
    # create the page
    click_button("Save")
    # veryify that the page was created
    expect(page).to have_content("Page was successfully created.")
    # visit the show page for the document we just saved
    visit spotlight.feature_page_path(id: Spotlight::FeaturePage.last)
    # veryify that the record thumbnail widget is displaying an image from the document.
    within(:css, ".panel.record-thumbnail") do
      expect(page).to have_css(".panel-body")
      expect(page).to have_css(".panel-body a img")
      expect(page).not_to have_css(".panel-footer")
    end
  end
  scenario "should allow you to optionally display the title with the image", :js => true do
    # create page
    # TODO find this via a menu
    visit spotlight.exhibit_catalog_index_path(Spotlight::Exhibit.default)
    click_link "Feature pages"
    click_link "Add new Page"
    # fill in title
    fill_in "feature_page_title", :with => "Exhibit Title"
    # click to add widget
    find("[data-icon='add']").click
    # click the Record Thumbnail widget
    expect(page).to have_css("a[data-type='record-thumbnail']")
    find("a[data-type='record-thumbnail']").click
    # fill in the record ID field
    expect(page).to have_css("input#record-thumbnail-id")
    fill_in "record-thumbnail-id", :with => "dq287tq6352"
    # display the title
    check("Show title?")
    # create the page
    click_button("Save")
    # veryify that the page was created
    expect(page).to have_content("Page was successfully created.")
    # visit the show page for the document we just saved
    visit spotlight.feature_page_path(id: Spotlight::FeaturePage.last)
    # veryify that the record thumbnail widget is displaying image and title from the requested document.
    within(:css, ".panel.record-thumbnail") do
      expect(page).to have_css(".panel-body")
      expect(page).to have_css(".panel-body a img")
      expect(page).to have_css(".panel-footer")
      expect(page).to have_content("L'AMERIQUE")
    end
  end
end
