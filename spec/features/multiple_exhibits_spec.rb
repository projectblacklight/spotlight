require "spec_helper"
describe "Home page" do
  let(:exhibit_visitor) { FactoryGirl.create(:exhibit_visitor) }
  let!(:default_exhibit) { Spotlight::ExhibitFactory.default }
  let!(:second_exhibit) { FactoryGirl.create(:exhibit, title: "Second exhibit") }

  before {login_as exhibit_visitor}

  it "should exist by default on exhibits" do
    visit '/'

    expect(page).to have_selector ".site-title", text: "Default exhibit"
    expect(page).to have_link "More Exhibits"
    within '#exhibit-navbar .dropdown-menu' do
      expect(page).to have_no_link "Default exhibit"
      click_link "Second exhibit"
    end

    expect(page).to have_selector ".site-title", text: "Second exhibit"
    expect(page).to have_link "More Exhibits"
    within '#exhibit-navbar .dropdown-menu' do
      expect(page).to have_no_link "Second exhibit"
      click_link "Default exhibit"
    end
    expect(page).to have_selector ".site-title", text: "Default exhibit"

  end
end

