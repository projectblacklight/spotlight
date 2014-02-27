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
    describe "item grid helpers" do
      describe "block objects" do
        let(:block1) { {'item-grid-id_0' => "abc", 'item-grid-id_1' => "cba", 'item-grid-display_0' => false, 'item-grid-display_1' => false} }
        let(:block_with_hidden) { {'item-grid-id_0' => "abc", 'item-grid-id_1' => "cba", 'item-grid-display_0' => false, 'item-grid-display_1' => true} }
        let(:block_with_blank) { {'item-grid-id_0' => "abc", 'item-grid-id_1' => "", 'item-grid-id_2' => "", 'item-grid-display_0' => true, 'item-grid-display_1' => false} }
        let(:bad_keys) { {'another-key' => "something"} }
        describe "item_grid_block_objects" do
          it "should get the items w/ item-grid-id in the key" do
            objects = helper.item_grid_block_objects(block1)
            expect(objects).to include({:id => "abc", :display => false})
            expect(objects).to include({:id => "cba", :display => false})
          end
          it "should get set the display attribute to true if a corresponding display field is set to 'true'" do
            objects = helper.item_grid_block_objects(block_with_hidden)
            expect(objects).to include({:id => "abc", :display => false})
            expect(objects).to include({:id => "cba", :display => true})
          end
          it "should omit any blank values" do
            objects = helper.item_grid_block_objects(block_with_blank)
            expect(objects).to eq([{:id => "abc", :display => true}])
          end
          it "should omit any unnecessary keys" do
            expect(helper.item_grid_block_objects(bad_keys)).to be_blank
          end
        end
        describe "item_grid_block_ids" do
          it "should get all of the displayable document IDs from the block" do
            expect(helper.item_grid_block_ids(block_with_hidden)).to eq ["cba"]
          end
          it "should omit blank keys" do
            expect(helper.item_grid_block_ids(block_with_blank)).to eq ["abc"]
          end
          it "should omit any unnecessary keys" do
            expect(helper.item_grid_block_ids(bad_keys)).to be_blank
          end
        end
      end
      describe "captions" do
        let(:solr_document) { ::SolrDocument.new(:id => "123", 'a_field' => "A field value") }
        it "should return the document_heading when the special title field is selected" do
          helper.should_receive(:document_heading).with(solr_document).and_return("A title")
          expect(helper.multi_up_item_grid_caption({'item-grid-caption-field' => 'spotlight_title_field'}, solr_document)).to eq "A title"
        end
        it "should render the field value when any other field is selected" do
          expect(helper.multi_up_item_grid_caption({'item-grid-caption-field' => 'a_field'}, solr_document)).to eq "A field value"
        end
        it "should do nothing if the item-grid-caption-field is blank or nil" do
          expect(helper.multi_up_item_grid_caption({'item-grid-caption-field' => ''}, solr_document)).to be_blank
          expect(helper.multi_up_item_grid_caption({}, solr_document)).to be_blank
        end
      end
    end
  end
end
