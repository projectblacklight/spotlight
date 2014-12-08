require 'spec_helper'

describe "Editing metadata fields", type: :feature do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:admin) { FactoryGirl.create(:exhibit_admin, exhibit: exhibit) }
  before { login_as(admin) }

  it "should allow curators to select and unselect facets for display" do
    visit spotlight.exhibit_edit_facets_path exhibit

    expect(page).to have_content "Curation Search Facets"
    expect(page).to have_button "Save"

    uncheck "blacklight_configuration_facet_fields_language_ssim_show" # Language
    uncheck "blacklight_configuration_facet_fields_genre_ssim_show" # Genre
    check   "blacklight_configuration_facet_fields_subject_temporal_ssim_show" # Era

    click_on "Save changes"

    expect(exhibit.reload.blacklight_config.facet_fields.select { |k,v| v.show }.keys).to include("subject_temporal_ssim")
    expect(exhibit.blacklight_config.facet_fields.select { |k,v| v.show }.keys).to_not include("language_ssim", "genre_ssim")
  end

  it "should display information about the facet" do
    visit spotlight.exhibit_edit_facets_path exhibit
    within  ".facet-config-genre_ssim" do
      expect(page).to have_content /\d+ items/
      expect(page).to have_content  /(\d+) unique values/
    end
  end

  it "should have breadcrumbs" do
    visit spotlight.exhibit_edit_facets_path exhibit

    expect(page).to have_breadcrumbs "Home", "Curation", "Search facets"
  end
end
