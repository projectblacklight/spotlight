require "spec_helper"

describe "Mutli-Up Item Grid", js: true do
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator) }
  let!(:exhibit) { Spotlight::Exhibit.default }
  let!(:feature_page) { FactoryGirl.create(:feature_page, exhibit: exhibit) }
  before { login_as exhibit_curator }
  it "should display items that are configured to display (and hide items that are not)" do
    pending("Passing locally but Travis is thowing intermittent errors") if ENV["CI"]
    visit '/'
    click_link exhibit_curator.email
    within '.dropdown-menu' do
      click_link 'Dashboard'
    end
    click_link "Feature pages"

    within("[data-id='#{feature_page.id}']") do
      click_link "Edit"
    end

    find("[data-icon='add']").click

    find("a[data-type='multi-up-item-grid']").click

    fill_in("item-grid-id_0", with: "dq287tq6352")
    check("item-grid-display_0")
    fill_in("item-grid-id_1", with: "jp266yb7109")
    check("item-grid-display_1")
    fill_in("item-grid-id_2", with: "zv316zr9542")

    click_button "Save changes"
    expect(page).to have_content("Page was successfully updated.")

    within("[data-id='#{feature_page.id}']") do
      click_link "View"
    end
    expect(page).to have_css("[data-id='dq287tq6352']")
    expect(page).to have_css("[data-id='jp266yb7109']")
    expect(page).not_to have_css("[data-id='zv316zr9542']")
  end
end