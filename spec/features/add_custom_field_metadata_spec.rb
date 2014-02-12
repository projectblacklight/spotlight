require 'spec_helper'

describe "Adding custom metadata field data", type: :feature do
  include Warden::Test::Helpers
  Warden.test_mode!

  before :each do
    admin = FactoryGirl.create(:exhibit_admin)
    custom_field = FactoryGirl.create(:custom_field)
    login_as(admin, :scope => :user)
    config = Spotlight::Exhibit.default.blacklight_configuration
    config.index_fields[custom_field.field] = { enabled: true, show: true }
    config.save!
  end

  it "should work" do
    visit solr_document_path("dq287tq6352")

    expect(page).to have_link "Enter curation mode."

    click_on "Enter curation mode."

    fill_in "Some Field", with: "My new custom field value"

    click_on "Save changes"

    expect(::SolrDocument.find("dq287tq6352").sidecar(Spotlight::Exhibit.default).data).to include "field_name" => "My new custom field value"

    visit solr_document_path("dq287tq6352")

    expect(page).to have_content "Some Field"
    expect(page).to have_content "My new custom field value"

  end
end