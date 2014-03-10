require 'spec_helper'

describe "Create a new exhibit" do
  let(:user) { FactoryGirl.create(:site_admin) }
  before {login_as user}

  it "should have a link in the user dropdown" do
    visit '/'
    within '.dropdown-menu' do
      click_link "Create Exhibit"
    end
    expect(page).to have_selector "h1", text: "Administration"
    expect(page).to have_selector "h1 small", text: "Create a new exhibit"
  end

  it "should allow admins to create a new exhibit" do
    visit '/'
    within '.dropdown-menu' do
      click_link "Create Exhibit"
    end

    fill_in "Title", with: "My exhibit title"
    fill_in "Subtitle", with: "Some subtitle"
    fill_in "Description", with: "A short description of the exhibit"

    click_button "Save"

    expect(page).to have_content "The exhibit was created."
  end
end
