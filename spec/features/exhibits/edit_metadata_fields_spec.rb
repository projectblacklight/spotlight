require 'spec_helper'

describe "Editing metadata fields", type: :feature do
  include Warden::Test::Helpers
  Warden.test_mode!

  before :each do
    admin = FactoryGirl.create(:exhibit_admin)
    login_as(admin, :scope => :user)
  end

  it "should work" do
    visit spotlight.exhibit_edit_metadata_path Spotlight::Exhibit.default

    expect(page).to have_content "Display and Order Metadata Fields"

    check :blacklight_configuration_index_fields_language_ssm_show
    check :blacklight_configuration_index_fields_language_ssm_list

    check :blacklight_configuration_index_fields_abstract_tesim_show
    check :blacklight_configuration_index_fields_note_mapuse_tesim_list

    click_on "Save changes"

    expect(Spotlight::Exhibit.default.blacklight_config('list').index_fields).to include("language_ssm", "note_mapuse_tesim")
    expect(Spotlight::Exhibit.default.blacklight_config('list').index_fields).to have(2).fields
    expect(Spotlight::Exhibit.default.blacklight_config.show_fields).to include("language_ssm", "abstract_tesim")
  end

  it "should have in-place editing of labels", js: true do
    visit spotlight.exhibit_edit_metadata_path Spotlight::Exhibit.default
    check :blacklight_configuration_index_fields_language_ssm_show
    check :blacklight_configuration_index_fields_language_ssm_list

    click_on "Language"

    expect(page).to have_field :blacklight_configuration_index_fields_language_ssm_label, visible: true
    fill_in :blacklight_configuration_index_fields_language_ssm_label, with: "Language of Origin"

    click_on "Save changes"
    expect(Spotlight::Exhibit.default.blacklight_config.index_fields['language_ssm'].label).to eq "Language of Origin"
  end
end
