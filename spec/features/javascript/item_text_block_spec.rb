require "spec_helper"

feature "Item + Image Block" do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  before { login_as exhibit_curator }

  scenario "should allow you to add a thumbnail to a page within an exhibit", :js => true do
    pending("Passing locally but Travis is throwing intermittent error because it doesn't seem to wait for form to be submitted.") if ENV["CI"]
    # create page
    visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)
    click_link exhibit_curator.email
    within '#user-util-collapse .dropdown' do
      click_link 'Dashboard'
    end
    click_link "Feature pages"

    add_new_page_via_button("My New Feature Page")

    expect(page).to have_css("h3", text: "My New Feature Page")

    expect(page).to have_content("The feature page was created.", visible: true)
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
    expect(page).to have_content("The feature page was successfully updated.", visible: true)
    # verify that the item + image widget is displaying an image from the document.
    within(:css, ".item-text") do
      expect(page).to have_css(".thumbnail")
      expect(page).to have_css(".thumbnail a img")
      expect(page).not_to have_css(".title")
    end
  end

  scenario "should allow you to optionally display captions with the image", :js => true do
    pending("Passing locally but Travis is throwing intermittent error because it doesn't seem to wait for form to be submitted.") if ENV["CI"]
    # create page
    visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)
    click_link exhibit_curator.email
    within '#user-util-collapse .dropdown' do
      click_link 'Dashboard'
    end
    click_link "Feature pages"

    add_new_page_via_button

    expect(page).to have_content("The feature page was created.", visible: true)
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
    item_id_field.set("gk446cj2442")
    # display the title as the primary caption
    within('.primary-caption') do
      check("Primary caption")
      select("Title", from: 'item-grid-primary-caption-field')
    end
    # display the language as the secondary caption
    within('.secondary-caption') do
      check("Secondary caption")
      select("Language", from: 'item-grid-secondary-caption-field')
    end
    # create the page
    click_button("Save changes")
    # verify that the page was created
    expect(page).to have_content("The feature page was successfully updated.", visible: true)

    # verify that the item + image widget is displaying image and title from the requested document.
    within(:css, ".item-text") do
      expect(page).to have_css(".thumbnail")
      expect(page).to have_css(".thumbnail a img")
      expect(page).to have_css(".primary-caption", text: "[World map]")
      expect(page).to have_css(".secondary-caption", text: "Latin")
    end
  end

  scenario "should allow you to add text to the image", :js => true do
    pending("Passing locally but Travis is throwing intermittent error because it doesn't seem to wait for form to be submitted.") if ENV["CI"]
    # create page
    visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)
    click_link exhibit_curator.email
    within '#user-util-collapse .dropdown' do
      click_link 'Dashboard'
    end
    click_link "Feature pages"

    add_new_page_via_button

    expect(page).to have_content("The feature page was created.", visible: true)
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

    # fill in the content-editable div
    content_editable = find(".st-text-block")
    content_editable.set("Some text to annotate this image.")
    # create the page
    click_button("Save changes")
    # verify that the page was created
    expect(page).to have_content("The feature page was successfully updated.", visible: true)
    # visit the show page for the document we just saved
    # verify that the item + image widget is displaying image and title from the requested document.
    within(:css, ".item-text") do
      expect(page).to have_content "Some text to annotate this image."
    end
  end

  scenario "should allow you to choose which side the text will be on", :js => true do
    pending("Passing locally but Travis is throwing intermittent error because it doesn't seem to wait for form to be submitted.") if ENV["CI"]
    # create page
    visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)
    click_link exhibit_curator.email
    within '#user-util-collapse .dropdown' do
      click_link 'Dashboard'
    end
    click_link "Feature pages"

    add_new_page_via_button

    expect(page).to have_content("The feature page was created.", visible: true)
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

    # fill in the content editable div
    content_editable = find(".st-text-block")
    content_editable.set("Some text to annotate this image.")
    # Select to align the text right
    choose "Right"
    # create the page
    click_button("Save changes")
    # verify that the page was created
    expect(page).to have_content("The feature page was successfully updated.", visible: true)
    # verify that the item + image widget is displaying image and title from the requested document.
    within(:css, ".item-text") do
      expect(page).to have_content "Some text to annotate this image."
      # should pull the image block the opposite direction of the configured text.
      expect(page).to have_css(".image-block.pull-left")
    end
  end
end
