require "spec_helper"

feature "Feature Pages Adminstration", js:  true do
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator) }
  let(:exhibit) { Spotlight::Exhibit.default }
  let!(:page1) {
    FactoryGirl.create(
      :feature_page,
      title: "FeaturePage1",
      exhibit: exhibit
    )
  }
  let!(:page2) {
    FactoryGirl.create(
      :feature_page,
      title: "FeaturePage2",
      exhibit: exhibit,
      display_sidebar: true
    )
  }
  before { login_as exhibit_curator }
  it "should update the page titles" do
    visit '/'
    click_link exhibit_curator.email

    within '.dropdown-menu' do
      click_link 'Dashboard'
    end

    click_link "Feature pages"
    within("[data-id='#{page1.id}']") do
      within("h3") do
        expect(page).to have_content("FeaturePage1")
      end
      click_link "Options"
      fill_in("Page title", with: "NewFeaturePage1")
    end
    click_button "Save changes"
    expect(page).to have_content("Feature pages were successfully updated.")
    within("[data-id='#{page1.id}']") do
      within("h3") do
        expect(page).to have_content("NewFeaturePage1")
      end
    end
  end
  it "should store the display_sidebar boolean" do
    visit '/'
    click_link exhibit_curator.email
    within '.dropdown-menu' do
      click_link 'Dashboard'
    end
    click_link "Feature pages"
    within("[data-id='#{page1.id}']") do
      click_link "Options"
      expect(field_labeled("Show sidebar")).to_not be_checked
      check "Show sidebar"
    end
    click_button "Save changes"
    within("[data-id='#{page1.id}']") do
      click_link "Options"
      expect(field_labeled("Show sidebar")).to be_checked
    end
  end
  it "should stay in curation mode if a user has unsaved data" do
    visit '/'
    click_link exhibit_curator.email
    within '.dropdown-menu' do
      click_link 'Dashboard'
    end
    click_link "Feature pages"
    within("[data-id='#{page1.id}']") do
      click_link "Edit"
    end
    fill_in("Title", with: "Some Fancy Title")
    click_link "Turn off."
    expect(page).to have_content "You are in curation mode."
  end
  it "should stay in curation mode if a user has unsaved contenteditable data" do
    visit '/'
    click_link exhibit_curator.email
    within '.dropdown-menu' do
      click_link 'Dashboard'
    end

    click_link "Feature pages"
    within("[data-id='#{page1.id}']") do
      click_link "Edit"
    end

    find("[data-icon='add']").click
    find("a[data-type='text']").click
    content_editable = find(".st-text-block")
    content_editable.set("Some Facnty Text.")

    click_link "Turn off."
    expect(page).to have_content "You are in curation mode."
  end
  it "should not update the pages list when the user has unsaved changes" do
    visit '/'
    click_link exhibit_curator.email
    within '.dropdown-menu' do
      click_link 'Dashboard'
    end

    click_link "Feature pages"
    within("[data-id='#{page1.id}']") do
      click_link "Options"
      fill_in("Page title", with: "NewFancyTitle")
    end
    click_link "Home"
    expect(page).not_to have_content("Feature pages were successfully updated.")
    expect(page).to have_css("h1 small", text: "Feature Pages")
  end
end
