require 'spec_helper'

describe Spotlight::ExhibitExportSerializer do
  let!(:source_exhibit) { FactoryGirl.create(:exhibit) }

  subject { JSON.parse(Spotlight::ExhibitExportSerializer.new(source_exhibit).to_json) }

  it "should not include unique identifiers" do
    expect(subject).to_not have_key 'id'
    expect(subject).to_not have_key 'slug'
    expect(subject).to_not have_key 'name'
    expect(subject).to_not have_key 'default'
  end

  it "should have search attributes" do
    expect(subject["searches"]).to have(source_exhibit.searches.count).searches
  end

  it "should have home page attributes" do
    expect(subject).to have_key "home_page"
    expect(subject['home_page']).to_not have_key 'id'
    expect(subject['home_page']).to_not have_key 'scope'
    expect(subject['home_page']).to_not have_key 'exhibit_id'
  end

  it "should have about pages" do
    expect(subject["about_pages"]).to have(source_exhibit.about_pages.count).pages
  end

  it "should have feature pages" do
    expect(subject["feature_pages"]).to have(source_exhibit.feature_pages.at_top_level.count).pages
  end

  it "should have custom fields" do
    expect(subject["custom_fields"]).to have(source_exhibit.custom_fields.count).items
  end

  it "should have contacts" do
    expect(subject["contacts"]).to have(source_exhibit.contacts.count).items
  end

  it "should have contact emails" do
    expect(subject["contact_emails"]).to have(source_exhibit.contact_emails.count).items
  end

  it "should have blacklight configuration attributes" do
    expect(subject).to have_key "blacklight_configuration"
  end

  it "should have solr document sidecars" do
    source_exhibit.solr_document_sidecars.create! solr_document_id: 1, public: false
    expect(subject["solr_document_sidecars"]).to have_at_least(1).item
    expect(subject["solr_document_sidecars"]).to have(source_exhibit.solr_document_sidecars.count).items
  
    expect(subject["solr_document_sidecars"].first).to include('solr_document_id', 'public')
    expect(subject["solr_document_sidecars"].first).to_not include 'id'
  end

  it "should have attachments" do
    expect(subject["attachments"]).to have(source_exhibit.attachments.count).items
  end

  it "should have resources" do
    expect(subject["resources"]).to have(source_exhibit.resources.count).items
  end

  it "should have tags" do
    source_exhibit.tag(SolrDocument.new(id: 1), with: "xyz", on: :tags)
    expect(subject["owned_taggings"]).to have(source_exhibit.owned_taggings.count).items
  end

  describe "should round-trip data" do
    before do
      source_exhibit.solr_document_sidecars.create! solr_document_id: 1, public: false
      source_exhibit.tag(SolrDocument.new(id: 1), with: "xyz", on: :tags)
    end

    let :export do
      Spotlight::ExhibitExportSerializer.new(source_exhibit).as_json
    end

    subject do
      e = FactoryGirl.create(:exhibit)
      e.import(export).tap { |e| e.save }
    end

    it "should have exhibit properties" do
      expect(subject.title).to eq source_exhibit.title
    end

    it "should not duplicate saved searches" do
      expect(subject.searches).to have(1).item
    end

    it "should have blacklight configuration properties" do
      expect(subject.blacklight_configuration).to be_persisted
    end

    it "should have home page properties" do
      expect(subject.home_page).to be_persisted
      expect(subject.home_page.id).not_to eq source_exhibit.home_page.id

      expect(subject.home_page.title).to eq source_exhibit.home_page.title
      expect(subject.home_page.content).to eq source_exhibit.home_page.content
    end

    it "should have sidecars" do
      expect(SolrDocument.new(id: 1).public? subject).to be_falsey
    end

    it "should have tags" do
      expect(subject.owned_taggings.length).to eq source_exhibit.owned_taggings.length
      expect(subject.owned_taggings.first).to be_persisted
      expect(subject.owned_taggings.first.tag.name).to eq "xyz"
    end
  end

  describe "should export saved searches with query parameters that can be re-generated" do
    before do
      source_exhibit.feature_pages.create content: [{:type=>"search_results", :data=>{:"slug"=>search.slug, :atom=>nil, :rss=>nil, :gallery=>nil, :slideshow=>nil, :list=>"on"}}].to_json
    end

    subject do
      e = FactoryGirl.create(:exhibit)
      e.import(export).tap { |e| e.save }
    end

    let :export do
      Spotlight::ExhibitExportSerializer.new(source_exhibit).as_json
    end

    context "with a search object with matching query params" do  
      let :search do
        source_exhibit.searches.first
      end

      it "should use a search within the exhibit" do
        expect(subject.feature_pages.first.content.first.search.exhibit).to eq subject
      end

      it "should use the existing search object with the same query params" do
        expect(subject.searches).to have(1).item
      end
    end

    context "with a search object that needs to be created" do
       let :search do
         source_exhibit.searches.create title: "custom query", slug: 'xyz'
       end

       it "should create a search within the exhibit" do
         expect(subject.feature_pages.first.content.first.search.exhibit).to eq subject
       end

       it "should use the existing search object with the same query params" do
         expect(subject.searches).to have(2).items
       end
    end
  end

end
