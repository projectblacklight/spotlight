require 'spec_helper'

module Spotlight
  describe PagesHelper do
    let(:blacklight_config) { Blacklight::Configuration.new { |config| config.show.title_field = :abc } }
    let(:titled_document)   { ::SolrDocument.new( :abc => "value" ) }
    let(:untitled_document) { ::SolrDocument.new( :id  => "1234"  ) }
    let!(:current_exhibit) { Spotlight::Exhibit.default }
    let!(:home_page) { current_exhibit.home_page }

    before(:each) do
      helper.stub(:blacklight_config => blacklight_config)
    end

    describe "has_title?" do
      it "should return true if the title is not the same as the ID" do
        expect(helper.has_title? titled_document).to be_true
      end
      it "should return false if the document heading returned is the same as the ID (indicating there is no title)" do
        expect(helper.has_title? untitled_document).to be_false
      end
    end
    describe "should_render_record_thumbnail_title?" do
      it "should return true if there is a title" do
        expect(helper.should_render_record_thumbnail_title?(titled_document, {'show-title' => true})).to be_true
      end
      it "should return false there is no title" do
        expect(helper.should_render_record_thumbnail_title?(untitled_document, {'show-title' => true})).to be_false
      end
      it "should return false if the block configuration is hiding the title" do
        expect(helper.should_render_record_thumbnail_title?(titled_document, {'show-title' => false})).to be_false
      end
    end
    describe "home_page_or_default_title" do
      it "should return the title of an object if present" do
        home_page.title = "Home Page Title"; home_page.save
        expect(helper.send(:home_page_or_default_title, current_exhibit.home_page)).to eq("Home Page Title")
      end
      it "should return the default i18n string when the title is blank" do
        home_page.title = ""; home_page.save
        expect(helper.send(:home_page_or_default_title, current_exhibit.home_page)).to eq("Exhibit Home")
      end
      it "should return the default i18n string if no title is present" do
        expect(helper.send(:home_page_or_default_title, current_exhibit.home_page)).to eq("Exhibit Home")
      end
    end
  end
end
