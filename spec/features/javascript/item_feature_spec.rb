require "spec_helper"

feature "Featured items" do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  before { login_as exhibit_curator }

  scenario "should update the active feature item when clicking", :js => true do
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
    add_widget 'item-features'
    # fill in the hidden record ID field

    fill_in_typeahead_field "item-grid-id_0_title", with: "dq287tq6352"
    fill_in_typeahead_field "item-grid-id_1_title", with: "jp266yb7109"

    # display the title as the primary caption
    within('.primary-caption') do
      check("Primary caption")
      select("Title", from: 'item-grid-primary-caption-field')
    end

    save_page

    within('.content-block.item-features') do
      expect(page).to have_css('.slideshow-indicators li', count: 2)

      expect(page).to have_css('.slideshow-indicators li.active a', text: "L'AMERIQUE")
      expect(page).to have_css('.slideshow-indicators li a',        text: "AMERICA")

      click_link("AMERICA")

      expect(page).to have_css('.slideshow-indicators li a',        text: "L'AMERIQUE")
      expect(page).to have_css('.slideshow-indicators li.active a', text: "AMERICA")
    end

  end
end