require 'spec_helper'

describe 'spotlight/sir_trevor/blocks/_item_features_block.html.erb', :type => :view do
  let(:p) { "spotlight/sir_trevor/blocks/item_features_block.html.erb" }
  let(:block) do
    double(with_solr_helper: nil, block_objects:
    [OpenStruct.new(id: '1', solr_document: ::SolrDocument.new(id: 1)),
      OpenStruct.new(id: '2', solr_document: ::SolrDocument.new(id: 2)),
      OpenStruct.new(id: '3', solr_document: ::SolrDocument.new(id: 3))]
      )
    end
    
    before do
      allow(view).to receive_messages(multi_up_item_grid_caption: 'caption')
      allow(view).to receive_messages(has_thumbnail?: true, render_thumbnail_tag: 'thumb')
    end
    
    it "should have a slideshow" do
      render partial: p, locals: { item_features_block: block }
      expect(rendered).to have_selector '.slideshow'
      expect(rendered).to have_selector '.item', text: 'thumb', count: 3
      expect(rendered).to have_selector '.slideshow-indicators'
      expect(rendered).to have_selector '.slideshow-indicators .list-group-item', count: 3 
    end
    it 'should truncated long titles (and keep the full title as the title attribute)' do
      caption = 'abcdef ' * 20
      allow(view).to receive_messages(multi_up_item_grid_caption: caption)
      render partial: p, locals: { item_features_block: block }
      expect(rendered).to have_selector '.slideshow-indicators .list-group-item', count: 3, text: /a\.\.\.$/
      expect(rendered).to have_selector ".slideshow-indicators .list-group-item a[title='#{caption}']"
    end
  end