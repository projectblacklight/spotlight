require 'spec_helper'

describe Spotlight::ExhibitExportSerializer do
  let!(:source_exhibit) { FactoryGirl.create(:exhibit) }

  subject { JSON.parse(Spotlight::ExhibitExportSerializer.new(source_exhibit).to_json) }

  it "should not include unique identifiers" do
    expect(subject).to_not have_key 'id'
    expect(subject).to_not have_key 'slug'
    expect(subject).to_not have_key 'name'
  end

  it "should have search attributes" do
    expect(subject["searches_attributes"]).to have(source_exhibit.searches.count).searches
  end

  it "should have home page attributes" do
    expect(subject).to have_key "home_page_attributes"
    expect(subject['home_page_attributes']).to_not have_key 'id'
    expect(subject['home_page_attributes']).to_not have_key 'scope'
    expect(subject['home_page_attributes']).to_not have_key 'exhibit_id'
  end

  it "should have about pages" do
    expect(subject["about_pages_attributes"]).to have(source_exhibit.about_pages.count).pages
  end

  it "should have feature pages" do
    expect(subject["feature_pages_attributes"]).to have(source_exhibit.feature_pages.at_top_level.count).pages
  end

  it "should have custom fields" do
    expect(subject["custom_fields_attributes"]).to have(source_exhibit.custom_fields.count).items
  end

  it "should have contacts" do
    expect(subject["contacts_attributes"]).to have(source_exhibit.contacts.count).items
  end

  it "should have contact emails" do
    expect(subject["contact_emails_attributes"]).to have(source_exhibit.contact_emails.count).items
  end

  it "should have blacklight configuration attributes" do
    expect(subject).to have_key "blacklight_configuration_attributes"
  end

  it "should have solr document sidecars" do
    source_exhibit.solr_document_sidecars.create! solr_document_id: 1, public: false
    expect(subject["solr_document_sidecars_attributes"]).to have_at_least(1).item
    expect(subject["solr_document_sidecars_attributes"]).to have(source_exhibit.solr_document_sidecars.count).items
  
    expect(subject["solr_document_sidecars_attributes"].first).to include('solr_document_id', 'public')
    expect(subject["solr_document_sidecars_attributes"].first).to_not include 'id'
  end

  it "should have attachments" do
    expect(subject["attachments_attributes"]).to have(source_exhibit.attachments.count).items
  end

end
