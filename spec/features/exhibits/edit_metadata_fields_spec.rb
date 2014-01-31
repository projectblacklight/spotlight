require 'spec_helper'

describe "Editing metadata fields", type: :feature do
  include Warden::Test::Helpers
  Warden.test_mode!

  before :each do
    admin = FactoryGirl.create(:exhibit_admin)
    login_as(admin, :scope => :user)
  end

  it "should work" do
    visit spotlight.edit_metadata_exhibit_path Spotlight::Exhibit.default

    expect(page).to have_content "Curation Metadata Fields"
    expect(page).to have_button "Save"

    select "Language", from: "List"
    select "Type", from: "List"

    click_on "Save changes"

    expect(Spotlight::Exhibit.default.blacklight_config('list').index_fields).to include("language_ssm", "note_mapuse_tesim")
    expect(Spotlight::Exhibit.default.blacklight_config('list').index_fields).to have(2).fields
  end
end