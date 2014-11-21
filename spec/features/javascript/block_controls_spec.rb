require "spec_helper"

feature "Block controls" do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  before { login_as exhibit_curator }

  scenario "should be split into separate sections", :js => true do
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
    find("[data-icon='add']").click

    within('.st-block-controls') do
      expect(page).to have_css(".st-controls-group", count: 2)
      within(first('.st-controls-group')) do
        expect(page).to have_content "Standard widgets"
        expect(page).to have_css('a.st-block-control')
      end
      within(all('.st-controls-group').last) do
        expect(page).to have_content "Exhibit item widgets"
        expect(page).to have_css('a.st-block-control')
      end
    end


  end
end