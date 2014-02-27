require "spec_helper"

feature "About Pages Adminstration", js:  true do
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator) }
  let(:exhibit) { Spotlight::Exhibit.default }
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
end
