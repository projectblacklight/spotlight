require 'spec_helper'

describe Spotlight::ApplicationHelper, :type => :helper do
  describe "#application_name" do
    it "should include the exhibit" do
      allow(helper).to receive_messages(current_exhibit: double(title: "My Exhibit"))
      expect(helper.application_name).to eq "My Exhibit - Blacklight"  
    end

    it "should be just the application name if there isn't an exhibit" do
      allow(helper).to receive_messages(current_exhibit: nil)
      expect(helper.application_name).to eq "Blacklight"  
    end
  end

  describe "#url_to_tag_facet" do
    before do
      allow(helper).to receive_messages(current_exhibit: FactoryGirl.create(:exhibit))
      allow(helper).to receive_messages(blacklight_config: Blacklight::Configuration.new)

      # controller provided helper.
      allow(helper).to receive(:search_action_url) do |*args|
        spotlight.exhibit_catalog_index_path(helper.current_exhibit, *args)
      end
    end

    it "should be a url for a search with the given tag facet" do
      allow(Spotlight::SolrDocument).to receive_messages(solr_field_for_tagger: :exhibit_tags)
      expect(helper.url_to_tag_facet "tag_value").to eq spotlight.exhibit_catalog_index_path(exhibit_id: helper.current_exhibit, f: { exhibit_tags: ['tag_value']})
    end
  end
  describe "search block helpers" do
    describe "selected_search_block_views" do
      it "should return keys with a value of 'on'" do
        expect(helper.selected_search_block_views(SirTrevorRails::Block.new({type: 'xyz', data: {a: "on", b: "off", c: false, d: "on"}}, 'parent'))).to eq ["a", "d"]
      end
    end
    describe "blacklight_view_config_for_search_block" do
      let(:sir_trevor_block) { 
        SirTrevorRails::Block.new({type: 'xyz', data: {"list" => "on", "gallery" => "on", "slideshow" => "null"}}, 'parent')
      }

      let(:config) { Blacklight::Configuration.new do |config|
        config.view.list = {}
        config.view.gallery = {}
        config.view.slideshow = {}
      end
      }
      before do
        allow(helper).to receive_messages(blacklight_config: config)
      end
      it "should return a blacklight configuration object that has reduced the views to those that are configured in the block" do
        expect(config.view.keys).to eq [:list, :gallery, :slideshow]
        new_config = helper.blacklight_view_config_for_search_block(sir_trevor_block)
        expect(new_config.keys).to eq [:list, :gallery]
      end
    end
  end
  describe 'render_document_class' do
    let(:current_exhibit) { FactoryGirl.create(:exhibit) }
    let(:document) { SolrDocument.new(some_field: "Some data") }
    before do
      allow(helper).to receive_messages(current_exhibit: current_exhibit)
      allow(helper).to receive_messages(blacklight_config: Blacklight::Configuration.new do |config|
        config.index.display_type_field = :some_field
      end)
    end
    it 'should return blacklight-private when the document is private' do
      allow(document).to receive(:private?).with(current_exhibit).and_return(true)
      expect(helper.render_document_class(document)).to match /blacklight-private/
    end
    it 'should prefix "blacklight-" to the configured type' do
      expect(helper.render_document_class(document)).to match /blacklight-some-data/
    end
  end

  describe "#add_exhibit_twitter_card_content" do
    let(:current_exhibit) { FactoryGirl.create(:exhibit) }
    before do
      allow(helper).to receive_messages(current_exhibit: current_exhibit)
      current_exhibit.subtitle = "xyz"
      current_exhibit.description = "abc"
      TopHat.current['twitter_card'] = nil
    end

    it "should generate a twitter card for the exhibit" do
      allow(helper).to receive(:exhibit_root_url).and_return("some/url")
      allow(current_exhibit).to receive(:featured_image).and_return(double(url: "http://some.host/image"))

      helper.add_exhibit_twitter_card_content

      card = helper.twitter_card
      expect(card).to have_css "meta[name='twitter:card'][value='summary']", visible: false
      expect(card).to have_css "meta[name='twitter:url'][value='some/url']", visible: false
      expect(card).to have_css "meta[name='twitter:title'][value='#{current_exhibit.title}']", visible: false
      expect(card).to have_css "meta[name='twitter:description'][value='#{current_exhibit.subtitle}']", visible: false
      expect(card).to have_css "meta[name='twitter:image'][value='http://some.host/image']", visible: false
    end
  end
  
  describe "#carrierwave_url" do
    it "should turn a application-relative URI into a path" do
      upload = double(url: "/x/y/z")
      expect(helper.carrierwave_url(upload)).to eq "http://test.host/x/y/z"
    end

    it "should pass a full URI through" do
      upload = double(url: "http://some.host/x/y/z")
      expect(helper.carrierwave_url(upload)).to eq "http://some.host/x/y/z"
    end
  end
end
