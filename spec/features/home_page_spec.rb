require "spec_helper"
describe "Home page" do
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator) }
  before {login_as exhibit_curator}
  it "should exist by default on exhibits" do
    visit spotlight.exhibit_catalog_index_path(Spotlight::Exhibit.default)
    click_link "Feature pages"
    expect(page).to have_selector "h3", text: "Exhibit Home"
  end
end
