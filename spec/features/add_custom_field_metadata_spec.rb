require 'spec_helper'

describe "Adding custom metadata field data" do
  let(:admin) { FactoryGirl.create(:exhibit_admin) }
  let(:custom_field) { FactoryGirl.create(:custom_field) }
  let(:config) { Spotlight::ExhibitFactory.default.blacklight_configuration }
  before do
    login_as(admin)
    config.index_fields[custom_field.field] = { enabled: true, show: true, 'label' => "Some Field" }
    config.save!
  end

  it "should work" do
    visit spotlight.exhibit_catalog_path(Spotlight::ExhibitFactory.default, "dq287tq6352")

    expect(page).to have_link "Edit"

    click_on "Edit"

    fill_in "Some Field", with: "My new custom field value"

    click_on "Save changes"

    expect(::SolrDocument.find("dq287tq6352").sidecar(Spotlight::ExhibitFactory.default).data).to include "field_name_tesim" => "My new custom field value"
    sleep(1) # The data isn't commited to solr immediately.

    visit spotlight.exhibit_catalog_path(Spotlight::ExhibitFactory.default, "dq287tq6352")
    expect(page).to have_content "Some Field"
    expect(page).to have_content "My new custom field value"

  end
end
