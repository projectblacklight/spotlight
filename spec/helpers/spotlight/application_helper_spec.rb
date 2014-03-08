require 'spec_helper'

describe Spotlight::ApplicationHelper do
  describe "#application_name" do
    it "should include the exhibit" do
      helper.stub(current_exhibit: double(title: "My Exhibit"))
      expect(helper.application_name).to eq "My Exhibit - Blacklight"  
    end

    it "should be just the application name if there isn't an exhibit" do
      helper.stub(current_exhibit: nil)
      expect(helper.application_name).to eq "Blacklight"  
    end
  end

  describe "#url_to_tag_facet" do
    before do
      helper.stub(current_exhibit: Spotlight::Exhibit.default)
      helper.stub(blacklight_config: Blacklight::Configuration.new)

      # controller provided helper.
      helper.stub(:search_action_url) do |*args|
        spotlight.exhibit_catalog_index_path(helper.current_exhibit, *args)
      end
    end

    it "should be a url for a search with the given tag facet" do
      Spotlight::SolrDocument.stub(solr_field_for_tagger: :exhibit_tags)
      expect(helper.url_to_tag_facet "tag_value").to eq spotlight.exhibit_catalog_index_path(exhibit_id: helper.current_exhibit, f: { exhibit_tags: ['tag_value']})
    end
  end
end
