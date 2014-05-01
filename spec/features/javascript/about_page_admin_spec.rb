require "spec_helper"

feature "About Pages Adminstration", js: true do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  before { login_as exhibit_curator }

  it "should be able to create new pages" do
    pending("Passing locally but Travis is throwing intermittent errors") if ENV["CI"]
    login_as exhibit_curator

    visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)
    click_link exhibit_curator.email

    within '#user-util-collapse .dropdown' do
      click_link 'Dashboard'
    end

    click_link "About pages"

    add_new_page_via_button("My New Page")

    expect(page).to have_content "The about page was created."
    expect(page).to have_css("li.dd-item")
    expect(page).to have_css("h3", text: "My New Page")
  end
end
