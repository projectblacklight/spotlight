require 'spec_helper'

module Spotlight
  describe PagesHelper, :type => :helper do
    let(:blacklight_config) { Blacklight::Configuration.new { |config| config.show.title_field = :abc } }
    let(:titled_document)   { ::SolrDocument.new( :abc => "value" ) }
    let(:untitled_document) { ::SolrDocument.new( :id  => "1234"  ) }
    let!(:current_exhibit) { FactoryGirl.create(:exhibit) }
    let!(:home_page) { current_exhibit.home_page }
    let!(:search) { FactoryGirl.create(:search, exhibit: current_exhibit, query_params: { "q" => "query" }) }

    before(:each) do
      allow(helper).to receive_messages(:blacklight_config => blacklight_config)
    end

    describe "has_title?" do
      it "should return true if the title is not the same as the ID" do
        expect(helper.has_title? titled_document).to be_truthy
      end
      it "should return false if the document heading returned is the same as the ID (indicating there is no title)" do
        expect(helper.has_title? untitled_document).to be_falsey
      end
    end
    describe "disable_save_pages_button?" do
      it "should return true if there are no pages and we are on the about pages page" do
        expect(helper).to receive(:page_collection_name).and_return("about_pages")
        assign(:pages, [])
        expect(helper.disable_save_pages_button?).to be_truthy
      end
      it "should return false if there are about pages" do
        expect(helper).to receive(:page_collection_name).and_return("about_pages")
        assign(:pages, [{}])
        expect(helper.disable_save_pages_button?).to be_falsey
      end
      it "should return false if on the feature pages page" do
        expect(helper).to receive(:page_collection_name).and_return("feature_pages")
        assign(:pages, [])
        expect(helper.disable_save_pages_button?).to be_falsey
      end
    end
    describe "get_search_widget_search_results" do
      let(:good_json) { { 'searches-options' => search.id } }
      let(:bad_json) { { 'searches-options' => 100 } }
      let(:search_result) { [double('response'), double('documents')] }
      it "should return the results for a given search browse category" do
        expect(helper).to receive(:get_search_results).with({"q" => "query"}).and_return(search_result)
        expect(helper.get_search_widget_search_results( good_json )).to eq search_result
      end
      it "should return an empty array when requesting a search that doesn't exist" do
        expect(helper.get_search_widget_search_results( bad_json )).to be_empty
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
        let(:solr_document) { ::SolrDocument.new(:id => "123", 'a_field' => "A field value", 'b_field' => "Another field value") }
        it "should return the document_heading when the special title field is selected" do
          expect(helper).to receive(:document_heading).with(solr_document).and_return("A title")
          expect(helper.multi_up_item_grid_caption({'item-grid-primary-caption-field' => 'spotlight_title_field'}, solr_document)).to eq "A title"
        end
        it "should render the field value when any other field is selected" do
          expect(helper.multi_up_item_grid_caption({'item-grid-primary-caption-field' => 'a_field'}, solr_document)).to eq "A field value"
        end
        it "should handle secondary caption fields" do
          expect(helper.multi_up_item_grid_caption({'item-grid-secondary-caption-field' => 'b_field'}, solr_document, 'secondary')).to eq "Another field value"
        end
        it "should do nothing if the item-grid-caption-field is blank or nil" do
          expect(helper.multi_up_item_grid_caption({'item-grid-primary-caption-field' => ''}, solr_document)).to be_blank
          expect(helper.multi_up_item_grid_caption({}, solr_document)).to be_blank
        end
      end
    end
    describe 'nestable helpers' do
      describe 'nestable data attributes' do
        it 'should return the appropriate attributes for feature pages' do
          expect(helper.nestable_data_attributes("feature_pages")).to eq "data-max-depth='2' data-expand-btn-HTML='' data-collapse-btn-HTML=''"
        end
        it 'should return the appropriate attributes for about pages' do
          expect(helper.nestable_data_attributes("about_pages")).to eq "data-max-depth='1'"
        end
        it 'should return a blank string if the type is not valid' do
          expect(helper.nestable_data_attributes("something_else")).to eq ""
        end
      end
      describe 'nestable data attributes hash' do
        it 'should return the appropriate hash for feature pages' do
          expect(helper.nestable_data_attributes_hash("feature_pages")).to eq({:"data-max-depth"=>"2", :"data-expand-btn-HTML"=>"", :"data-collapse-btn-HTML"=>""})
        end
        it 'should return the appropriate hash for about pages' do
          expect(helper.nestable_data_attributes_hash("about_pages")).to eq({:"data-max-depth"=>"1"})
        end
        it 'should return an empty hash if the type is not valid' do
          expect(helper.nestable_data_attributes_hash("something_else")).to eq({})
        end
      end
    end
  end
end
