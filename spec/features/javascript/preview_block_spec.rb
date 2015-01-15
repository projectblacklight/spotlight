require "spec_helper"

feature "Block preview" do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  before { login_as exhibit_curator }

  scenario "should allow you to preview a widget", :js => true do
    skip("Passing locally but Travis is throwing intermittent error because it doesn't seem to wait for form to be submitted.") if ENV["CI"]
    # create page
    visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)
    click_link exhibit_curator.email
    within '#user-util-collapse .dropdown' do
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
    add_widget 'item-text'
    # fill in the hidden record ID field
    # TODO: Do we need an additional test for the typeahead?
    item_id_field = find("input[name='item-id']", visible: false)
    item_id_field.set("dq287tq6352")

    # display the title as the primary caption
    within('.primary-caption') do
      check("Primary caption")
      select("Title", from: 'item-grid-primary-caption-field')
    end

    # create the page
    click_button("Preview")
    # verify that the page was created
    expect(page).to have_css('.preview')
    # verify that the item + image widget is displaying an image from the document.
    within(:css, ".preview") do
      expect(page).to have_css "img"
      expect(page).to have_content "L'AMERIQUE"
    end
  end
end