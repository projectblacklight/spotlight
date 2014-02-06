require 'spec_helper'

describe "Editing metadata fields", type: :feature do
  include Warden::Test::Helpers
  Warden.test_mode!

  before :each do
    admin = FactoryGirl.create(:exhibit_admin)
    login_as(admin, :scope => :user)
  end

  it "should allow curators to select and unselect facets for display" do
    visit spotlight.exhibit_edit_facets_path Spotlight::Exhibit.default

    expect(page).to have_content "Curation Search Facets"
    expect(page).to have_button "Save"

    uncheck "Language"
    uncheck "Genre"
    check "Era"

    click_on "Save changes"

    expect(Spotlight::Exhibit.default.blacklight_config.facet_fields.keys).to include("subject_temporal_sim")
    expect(Spotlight::Exhibit.default.blacklight_config.facet_fields.keys).to_not include("language_sim", "genre_sim")
  end

  it "should allow curators to set facet labels" do
    visit spotlight.exhibit_edit_facets_path Spotlight::Exhibit.default

    within ".facet-config-genre_sim" do
      click_on "Options"
      fill_in "Display Label", with: "Some Label"
    end

    click_on "Save changes"

    expect(Spotlight::Exhibit.default.blacklight_config.facet_fields['genre_sim'].label).to eq "Some Label"
  end

  it "should display information about the facet" do
    visit spotlight.exhibit_edit_facets_path Spotlight::Exhibit.default
    within  ".facet-config-genre_sim" do
      expect(page).to have_content /\d+ items/
      expect(page).to have_content  /(\d+) unique values/
      expect(page).to have_link "#{$1} unique values", href: catalog_facet_path('genre_sim')
    end
  end
end