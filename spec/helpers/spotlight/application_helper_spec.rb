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
      helper.stub(current_exhibit: FactoryGirl.create(:exhibit))
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
  describe "search block helpers" do
    describe "selected_search_block_views" do
      it "should return keys with a value of 'on'" do
        expect(helper.selected_search_block_views({a: "on", b: "off", c: false, d: "on"})).to eq [:a, :d]
      end
    end
    describe "blacklight_view_config_for_search_block" do
      let(:sir_trevor_json) { { "list" => "on", "gallery" => "on", "slideshow" => "null" } }
      let(:config) { Blacklight::Configuration.new }
      before do
        helper.stub(blacklight_config: config)
      end
      it "should return a blacklight configuration object that has reduced the views to those that are configured in the block" do
        expect(config.view.keys).to eq [:list, :gallery, :slideshow]
        new_config = helper.blacklight_view_config_for_search_block(sir_trevor_json)
        expect(new_config).to be_a (Blacklight::Configuration)
        expect(new_config.view.keys).to eq [:list, :gallery]
      end
    end
  end
end
