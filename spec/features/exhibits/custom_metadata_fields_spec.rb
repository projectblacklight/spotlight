require 'spec_helper'

describe "Adding custom metadata fields", type: :feature do
  include Warden::Test::Helpers
  Warden.test_mode!

  before :each do
    admin = FactoryGirl.create(:exhibit_admin)
    login_as(admin, :scope => :user)
  end

  it "should work" do
    visit spotlight.exhibit_edit_metadata_path Spotlight::Exhibit.default

    expect(page).to have_link "Add new exhibit-specific field"

    click_on "Add new exhibit-specific field"

    fill_in "Label", with: "My new custom field"

    click_on "Create Custom field"

    expect(Spotlight::Exhibit.default.custom_fields.last.label).to eq "My new custom field"

    expect(page).to have_content "My new custom field"
  end
end