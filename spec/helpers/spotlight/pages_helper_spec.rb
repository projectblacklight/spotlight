require 'spec_helper'

module Spotlight
  describe PagesHelper, :type => :helper do
    let(:blacklight_config) { Blacklight::Configuration.new { |config| config.show.title_field = :abc } }
    let(:titled_document)   { ::SolrDocument.new( :abc => "value" ) }
    let(:untitled_document) { ::SolrDocument.new( :id  => "1234"  ) }
    let!(:current_exhibit) { FactoryGirl.create(:exhibit) }
    let!(:home_page) { current_exhibit.home_page }
    let!(:search) { FactoryGirl.create(:search, exhibit: current_exhibit, query_params: { "q" => "query" }, on_landing_page: true ) }

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
      let(:good) { SirTrevorRails::Blocks::SearchResultsBlock.new({type: 'xyz', data: {'item' => { search.slug => { id: search.slug, display: "true" }}}}, home_page) }
      let(:bad) { SirTrevorRails::Blocks::SearchResultsBlock.new({type: 'xyz', data: { 'item' => { 'garbage' => { id: 'missing', display: "true" }}}}, home_page) }
      let(:search_result) { [double('response'), double('documents')] }
      it "should return the results for a given search browse category" do
        expect(helper).to receive(:get_search_results).with({"q" => "query"}).and_return(search_result)
        expect(helper.get_search_widget_search_results( good )).to eq search_result
      end
      it "should return an empty array when requesting a search that doesn't exist" do
        expect(helper.get_search_widget_search_results( bad )).to be_empty
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
