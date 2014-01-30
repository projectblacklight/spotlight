require 'spec_helper'

module Spotlight
  describe PagesHelper do
    let(:blacklight_config) { OpenStruct.new( :show => OpenStruct.new( :heading => :abc ) ) }
    let(:titled_document)   { SolrDocument.new( :abc => "value" ) }
    let(:untitled_document) { SolrDocument.new( :id  => "1234"  ) }
    before(:each) { helper.stub(:blacklight_config => blacklight_config) }

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
  end
end
