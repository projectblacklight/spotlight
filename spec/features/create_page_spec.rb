require "spec_helper"

describe "Creating a page", :type => :feature do
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator) }

  describe "when a bunch of about pages exist" do
    let!(:page1) { FactoryGirl.create(:about_page) }
    let!(:page2) { FactoryGirl.create(:about_page, exhibit: page1.exhibit) }
    let!(:page3) { FactoryGirl.create(:about_page, exhibit: page1.exhibit, title: "A new one") }
    it "should be able to show a list of About pages to be curated" do
      login_as exhibit_curator
      visit '/'
      within '.dropdown' do
        click_link 'Curation'
      end
      within '#sidebar' do
        click_link "About pages"
      end
      expect(page).to have_content "A new one"
    end
  end

  it "should be able to create new About Pages" do
    login_as exhibit_curator

    visit '/'
    within '.dropdown-menu' do
      click_link 'Curation'
    end

    click_link "About pages"
    click_button "Add new page"
    expect(page).to have_content "Page was successfully created."
    expect(page).to have_css("li.dd-item")
  end
end
