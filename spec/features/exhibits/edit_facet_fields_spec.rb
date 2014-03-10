require 'spec_helper'

describe "Editing metadata fields", type: :feature do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:admin) { FactoryGirl.create(:exhibit_admin, exhibit: exhibit) }
  before { login_as(admin) }

  it "should allow curators to select and unselect facets for display" do
    visit spotlight.exhibit_edit_facets_path exhibit

    expect(page).to have_content "Curation Search Facets"
    expect(page).to have_button "Save"

    uncheck "Language"
    uncheck "Genre"
    check "Era"

    click_on "Save changes"

    expect(exhibit.reload.blacklight_config.facet_fields.select { |k,v| v.show }.keys).to include("subject_temporal_ssim")
    expect(exhibit.blacklight_config.facet_fields.select { |k,v| v.show }.keys).to_not include("language_ssim", "genre_ssim")
  end

  it "should allow curators to set facet labels" do
    visit spotlight.exhibit_edit_facets_path exhibit

    within ".facet-config-genre_ssim" do
      click_on "Options"
      fill_in "Display Label", with: "Some Label"
    end

    click_on "Save changes"

    expect(exhibit.reload.blacklight_config.facet_fields['genre_ssim'].label).to eq "Some Label"
  end

  it "should display information about the facet" do
    visit spotlight.exhibit_edit_facets_path exhibit
    within  ".facet-config-genre_ssim" do
      expect(page).to have_content /\d+ items/
      expect(page).to have_content  /(\d+) unique values/
      expect(page).to have_link "#{$1} unique values", href: catalog_facet_path('genre_ssim')
    end
  end
end
