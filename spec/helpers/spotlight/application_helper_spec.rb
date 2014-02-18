require 'spec_helper'

describe Spotlight::ApplicationHelper do
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
      expect(helper.url_to_tag_facet "tag_value").to eq spotlight.exhibit_catalog_index_path(exhibit_id: 1, f: { exhibit_tags: ['tag_value']})
    end
  end
end