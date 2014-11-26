require "spec_helper"

describe "Multi image selector", type: :feature, js: true do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  let!(:feature_page) { FactoryGirl.create(:feature_page, exhibit: exhibit) }
  before { login_as exhibit_curator }

  it "should allow the user to select which image in a multi image object to display" do
    skip("Passing locally but Travis is throwing intermittent errors") if ENV["CI"]
    visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)
    click_link exhibit_curator.email
    within '#user-util-collapse .dropdown' do
      click_link 'Dashboard'
    end
    click_link "Feature pages"

    within("[data-id='#{feature_page.id}']") do
      click_link "Edit"
    end

    find("[data-icon='add']").click

    find("a[data-type='multi-up-item-grid']").click

    fill_in_typeahead_field "item-grid-id_0_title", with: "xd327cm9378"


    click_button "Save changes"
    expect(page).to have_content("The feature page was successfully updated.")

    visit spotlight.exhibit_feature_page_path(exhibit, feature_page)

    expect(page).to have_css("[data-id='xd327cm9378']")
    expect(page).to     have_css("img[src='https://stacks.stanford.edu/image/xd327cm9378/xd327cm9378_05_0001_thumb']")
    expect(page).to_not have_css("img[src='https://stacks.stanford.edu/image/xd327cm9378/xd327cm9378_05_0002_thumb']")

    click_link("Edit")

    within('.item-grid-admin') do
      expect(page).to have_content(/Image \d of \d/)
      click_link("Change")
    end

    expect(page).to have_css(".thumbs-list ul", visible: true)

    within(".thumbs-list ul") do
      all('li')[1].trigger('click')
    end

    click_button "Save changes"

    expect(page).to have_css("[data-id='xd327cm9378']")
    expect(page).to_not have_css("img[src='https://stacks.stanford.edu/image/xd327cm9378/xd327cm9378_05_0001_thumb']")
    expect(page).to     have_css("img[src='https://stacks.stanford.edu/image/xd327cm9378/xd327cm9378_05_0002_thumb']")
  end
end
