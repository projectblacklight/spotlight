require 'spec_helper'

module Spotlight
  describe PagesHelper, type: :helper do
    let(:blacklight_config) { Blacklight::Configuration.new { |config| config.show.title_field = :abc } }
    let(:titled_document) { blacklight_config.document_model.new(abc: 'value') }
    let(:untitled_document) { blacklight_config.document_model.new(id: '1234') }
    let!(:current_exhibit) { FactoryGirl.create(:exhibit) }
    let!(:home_page) { current_exhibit.home_page }
    let!(:search) { FactoryGirl.create(:search, exhibit: current_exhibit, query_params: { 'q' => 'query' }, published: true) }

    before(:each) do
      allow(helper).to receive_messages(blacklight_config: blacklight_config)
    end

    describe 'available_index_fields' do
      before do
        blacklight_config.index.title_field = :title_field
        blacklight_config.add_index_field 'x', label: 'X'
      end

      it 'lists the configured index fields' do
        expect(helper.available_index_fields).to include key: 'x', label: 'X'
      end

      it 'adds the title field if necessary' do
        expect(helper.available_index_fields).to include key: :title_field, label: 'Title'
      end
    end

    describe 'disable_save_pages_button?' do
      it 'returns true if there are no pages and we are on the about pages page' do
        expect(helper).to receive(:page_collection_name).and_return('about_pages')
        assign(:pages, [])
        expect(helper.disable_save_pages_button?).to be_truthy
      end
      it 'returns false if there are about pages' do
        expect(helper).to receive(:page_collection_name).and_return('about_pages')
        assign(:pages, [{}])
        expect(helper.disable_save_pages_button?).to be_falsey
      end
      it 'returns false if on the feature pages page' do
        expect(helper).to receive(:page_collection_name).and_return('feature_pages')
        assign(:pages, [])
        expect(helper.disable_save_pages_button?).to be_falsey
      end
    end
    describe 'get_search_widget_search_results' do
      let(:good) do
        content = { type: 'xyz', data: { 'item' => { search.slug => { id: search.slug, display: 'true' } } } }
        SirTrevorRails::Blocks::SearchResultsBlock.new(content, home_page)
      end

      let(:bad) do
        content = { type: 'xyz', data: { 'item' => { 'garbage' => { id: 'missing', display: 'true' } } } }
        SirTrevorRails::Blocks::SearchResultsBlock.new(content, home_page)
      end

      let(:search_result) { [double('response'), double('documents')] }

      it 'returns the results for a given search browse category' do
        allow(helper).to receive(:search_params_logic).and_return([])
        expect(helper).to receive(:search_results).with({ 'q' => 'query' }, []).and_return(search_result)
        expect(helper.get_search_widget_search_results(good)).to eq search_result
      end
      it "returns an empty array when requesting a search that doesn't exist" do
        expect(helper.get_search_widget_search_results(bad)).to be_empty
      end
    end

    describe 'nestable helpers' do
      describe 'nestable data attributes' do
        it 'returns the appropriate attributes for feature pages' do
          expect(helper.nestable_data_attributes('feature_pages')).to eq "data-max-depth='2' data-expand-btn-HTML='' data-collapse-btn-HTML=''"
        end
        it 'returns the appropriate attributes for about pages' do
          expect(helper.nestable_data_attributes('about_pages')).to eq "data-max-depth='1'"
        end
        it 'returns a blank string if the type is not valid' do
          expect(helper.nestable_data_attributes('something_else')).to eq ''
        end
      end
      describe 'nestable data attributes hash' do
        it 'returns the appropriate hash for feature pages' do
          expect(helper.nestable_data_attributes_hash('feature_pages')).to eq('data-max-depth' => '2',
                                                                              'data-expand-btn-HTML' => '',
                                                                              'data-collapse-btn-HTML' => '')
        end
        it 'returns the appropriate hash for about pages' do
          expect(helper.nestable_data_attributes_hash('about_pages')).to eq 'data-max-depth' => '1'
        end
        it 'returns an empty hash if the type is not valid' do
          expect(helper.nestable_data_attributes_hash('something_else')).to eq({})
        end
      end
    end
  end
end
