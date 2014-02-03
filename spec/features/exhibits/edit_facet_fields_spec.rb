require 'spec_helper'

describe "Editing metadata fields", type: :feature do
  include Warden::Test::Helpers
  Warden.test_mode!

  before :each do
    admin = FactoryGirl.create(:exhibit_admin)
    login_as(admin, :scope => :user)
  end

  it "should work" do
    visit spotlight.edit_facets_exhibit_path Spotlight::Exhibit.default

    expect(page).to have_content "Curation Search Facets"
    expect(page).to have_button "Save"

    select "Language", from: "Facet fields"
    select "Genre", from: "Facet fields"

    click_on "Save changes"

    expect(Spotlight::Exhibit.default.blacklight_config.facet_fields).to include("language_sim", "genre_sim")
    expect(Spotlight::Exhibit.default.blacklight_config.facet_fields).to have(2).fields
  end
end