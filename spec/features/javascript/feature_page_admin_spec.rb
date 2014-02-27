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
  it "should be able to create new pages" do
    pending("Passing locally but Travis is thowing intermittent errors") if ENV["CI"]
    login_as exhibit_curator

    visit '/'
    click_link exhibit_curator.email

    within '.dropdown-menu' do
      click_link 'Dashboard'
    end

    click_link "Feature pages"

    add_new_page_via_button("My New Page")

    expect(page).to have_content "Page was successfully created."
    expect(page).to have_css("li.dd-item")
    expect(page).to have_css("h3", text: "My New Page")
  end
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
        expect(page).to have_css("input", visible: false)
        click_link("FeaturePage1")
        expect(page).to have_css("input", visible: true)
        find("input").set("NewFeaturePage1")
      end
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
      expect(field_labeled("Show sidebar")).to_not be_checked
      check "Show sidebar"
    end
    click_button "Save changes"
    within("[data-id='#{page1.id}']") do
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
    click_link "Cancel"
    expect(page).not_to have_selector 'a', text: "Edit"
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

    click_link "Cancel"
    expect(page).not_to have_selector 'a', text: "Edit"
  end
  it "should not update the pages list when the user has unsaved changes" do
    visit '/'
    click_link exhibit_curator.email
    within '.dropdown-menu' do
      click_link 'Dashboard'
    end

    click_link "Feature pages"
    within("[data-id='#{page1.id}']") do
      within("h3") do
        expect(page).to have_content("FeaturePage1")
        expect(page).to have_css("input", visible: false)
        click_link("FeaturePage1")
        expect(page).to have_css("input", visible: true)
        find("input").set("NewFancyTitle")
      end
    end
    within '#exhibit-navbar' do
      click_link "Home"
    end
    expect(page).not_to have_content("Feature pages were successfully updated.")
    expect(page).to have_css("h1 small", text: "Feature Pages")
  end
end
